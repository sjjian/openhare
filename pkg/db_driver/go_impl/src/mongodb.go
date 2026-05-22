package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/url"
	"strings"
	"time"

	"github.com/bytebase/gomongo"
	"github.com/bytebase/gomongo/types"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
	"go.mongodb.org/mongo-driver/v2/mongo/readpref"
)

// 与 impl.go 中 GO_IMPL_QUERY_VALUE_STRING 一致（mongodb.go 无 cgo 的 import "C"）
const goImplQueryValueString int32 = 7

type mongoConn struct {
	client    *mongo.Client
	defaultDB string
	shell     *gomongo.Client
}

func defaultDBFromURI(uri string) string {
	u, err := url.Parse(uri)
	if err != nil {
		return "test"
	}
	path := strings.TrimPrefix(u.Path, "/")
	if i := strings.IndexAny(path, "/?"); i >= 0 {
		path = path[:i]
	}
	if path == "" {
		return "test"
	}
	return path
}

func openMongoConn(dsn string) (driverConn, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	opts := options.Client().
		ApplyURI(dsn).
		SetServerSelectionTimeout(30 * time.Second).
		SetConnectTimeout(15 * time.Second)
	client, err := mongo.Connect(opts)
	if err != nil {
		return nil, err
	}
	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		_ = client.Disconnect(ctx)
		return nil, err
	}
	return &mongoConn{
		client:    client,
		defaultDB: defaultDBFromURI(dsn),
		shell:     gomongo.NewClient(client),
	}, nil
}

func (c *mongoConn) Close() error {
	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()
	return c.client.Disconnect(ctx)
}

// mongoQueryWire 与 Dart 约定：{"shell":"...","db":"...","maxRows":可选}
type mongoQueryWire struct {
	DB      string `json:"db"`
	Shell   string `json:"shell"`
	MaxRows int64  `json:"maxRows"`
}

func (c *mongoConn) KillQuery() error {
	return nil
}

func (c *mongoConn) OpenQuery(sql string) (rowCursor, error) {
	sql = strings.TrimSpace(sql)
	if sql == "" {
		return nil, errors.New("mongodb: empty query")
	}
	execShell := sql
	execDB := c.defaultDB
	var gopts []gomongo.ExecuteOption

	var wire mongoQueryWire
	if err := json.Unmarshal([]byte(sql), &wire); err == nil && strings.TrimSpace(wire.Shell) != "" {
		execShell = strings.TrimSpace(wire.Shell)
		if d := strings.TrimSpace(wire.DB); d != "" {
			execDB = d
		}
		if wire.MaxRows > 0 {
			gopts = append(gopts, gomongo.WithMaxRows(wire.MaxRows))
		}
	}

	ctx := context.Background()
	res, err := c.shell.Execute(ctx, execDB, execShell, gopts...)
	if err != nil {
		return nil, err
	}
	return gomongoResultToCursor(res)
}

func bsonRawToJSONCell(raw bson.Raw) (dbQueryValue, error) {
	b, err := bson.MarshalExtJSON(raw, true, false)
	if err != nil {
		return dbQueryValue{}, err
	}
	return dbQueryValue{valueType: goImplQueryValueString, bytesValue: b}, nil
}

func singleValueCursor(col string, v int64, affected int64) rowCursor {
	return &mongoMemCur{
		header: &dbQueryHeader{
			columns:      []dbQueryColumn{{name: col, dataType: dataTypeNumber}},
			affectedRows: affected,
		},
		rows: [][]dbQueryValue{
			{buildQueryValue(v)},
		},
	}
}

func stringSliceCursor(col string, vals []string, affected int64) rowCursor {
	rows := make([][]dbQueryValue, len(vals))
	for i, s := range vals {
		rows[i] = []dbQueryValue{buildQueryValue(s)}
	}
	return &mongoMemCur{
		header: &dbQueryHeader{
			columns:      []dbQueryColumn{{name: col, dataType: dataTypeChar}},
			affectedRows: affected,
		},
		rows: rows,
	}
}

func singleRowJSONCursor(col string, cell dbQueryValue, affected int64) rowCursor {
	return &mongoMemCur{
		header: &dbQueryHeader{
			columns:      []dbQueryColumn{{name: col, dataType: dataTypeJson}},
			affectedRows: affected,
		},
		rows: [][]dbQueryValue{{cell}},
	}
}

type mongoMemCur struct {
	header *dbQueryHeader
	rows   [][]dbQueryValue
	idx    int
}

func (q *mongoMemCur) Close() error { return nil }

func (q *mongoMemCur) Header() *dbQueryHeader { return q.header }

func (q *mongoMemCur) NextRow() (*dbQueryRow, bool, error) {
	if q.idx >= len(q.rows) {
		return nil, false, nil
	}
	r := &dbQueryRow{values: q.rows[q.idx]}
	q.idx++
	return r, true, nil
}

// gomongoResultToCursor 将 [github.com/bytebase/gomongo] 的 Result 转为统一行游标。
func gomongoResultToCursor(res *gomongo.Result) (rowCursor, error) {
	if res == nil {
		return nil, fmt.Errorf("mongodb: nil gomongo result")
	}
	op := res.Operation
	vals := res.Value

	switch op {
	case types.OpFind, types.OpAggregate, types.OpGetIndexes, types.OpGetCollectionInfos, types.OpLatencyStats:
		return gomongoBsonDRowsCursor(vals, int64(len(vals)))

	case types.OpFindOne, types.OpFindOneAndUpdate, types.OpFindOneAndReplace, types.OpFindOneAndDelete:
		return gomongoBsonDRowsCursor(vals, int64(len(vals)))

	case types.OpCountDocuments, types.OpEstimatedDocumentCount:
		if len(vals) != 1 {
			return nil, fmt.Errorf("mongodb: gomongo count unexpected value count %d", len(vals))
		}
		n, ok := mongoGomongoToInt64(vals[0])
		if !ok {
			return nil, fmt.Errorf("mongodb: gomongo count unexpected type %T", vals[0])
		}
		return singleValueCursor("count", n, n), nil

	case types.OpDistinct:
		return gomongoScalarRowsCursor(vals)

	case types.OpShowDatabases, types.OpShowCollections, types.OpGetCollectionNames:
		return gomongoStringRowsCursor(vals)

	case types.OpInsertOne, types.OpInsertMany, types.OpUpdateOne, types.OpUpdateMany, types.OpReplaceOne,
		types.OpDeleteOne, types.OpDeleteMany, types.OpCreateIndex, types.OpCreateIndexes:
		return gomongoResultDocCursor(vals)

	case types.OpDropIndex, types.OpDropIndexes, types.OpCreateCollection, types.OpDropDatabase, types.OpRenameCollection,
		types.OpDbStats, types.OpCollectionStats, types.OpServerStatus, types.OpServerBuildInfo, types.OpHostInfo, types.OpListCommands, types.OpValidate:
		return gomongoResultDocCursor(vals)

	case types.OpDrop:
		if len(vals) == 1 {
			if b, ok := vals[0].(bool); ok && b {
				return singleValueCursor("ok", 1, 1), nil
			}
		}
		return gomongoScalarRowsCursor(vals)

	case types.OpDbVersion:
		if len(vals) != 1 {
			return nil, fmt.Errorf("mongodb: gomongo version unexpected value count %d", len(vals))
		}
		s, ok := vals[0].(string)
		if !ok {
			return nil, fmt.Errorf("mongodb: gomongo version unexpected type %T", vals[0])
		}
		return stringSliceCursor("version", []string{s}, 1), nil

	case types.OpDataSize, types.OpStorageSize, types.OpTotalIndexSize, types.OpTotalSize:
		if len(vals) != 1 {
			return nil, fmt.Errorf("mongodb: gomongo size op unexpected value count %d", len(vals))
		}
		n, ok := mongoGomongoToInt64(vals[0])
		if !ok {
			return nil, fmt.Errorf("mongodb: gomongo size unexpected type %T", vals[0])
		}
		return singleValueCursor("bytes", n, n), nil

	case types.OpIsCapped:
		if len(vals) == 1 {
			if b, ok := vals[0].(bool); ok {
				v := int64(0)
				if b {
					v = 1
				}
				return singleValueCursor("capped", v, 1), nil
			}
		}
		return gomongoScalarRowsCursor(vals)

	case types.OpUnknown:
		return nil, fmt.Errorf("mongodb: gomongo unknown operation")

	default:
		if len(vals) == 0 {
			return singleValueCursor("ok", 1, 0), nil
		}
		if len(vals) == 1 {
			if row, err := gomongoSingleValueRow(vals[0]); err == nil {
				return &mongoMemCur{
					header: &dbQueryHeader{
						columns:      []dbQueryColumn{{name: "value", dataType: dataTypeJson}},
						affectedRows: 1,
					},
					rows: [][]dbQueryValue{row},
				}, nil
			}
		}
		return gomongoBsonDRowsCursor(vals, int64(len(vals)))
	}
}

func mongoGomongoToInt64(v interface{}) (int64, bool) {
	switch x := v.(type) {
	case int64:
		return x, true
	case int32:
		return int64(x), true
	case int:
		return int64(x), true
	case float64:
		return int64(x), true
	default:
		return 0, false
	}
}

func gomongoBsonDRowsCursor(vals []any, affected int64) (rowCursor, error) {
	rows := make([][]dbQueryValue, 0, len(vals))
	for _, v := range vals {
		cell, err := mongoValueToJSONCell(v)
		if err != nil {
			return nil, err
		}
		rows = append(rows, []dbQueryValue{cell})
	}
	return &mongoMemCur{
		header: &dbQueryHeader{
			columns:      []dbQueryColumn{{name: "document", dataType: dataTypeJson}},
			affectedRows: affected,
		},
		rows: rows,
	}, nil
}

func gomongoStringRowsCursor(vals []any) (rowCursor, error) {
	ss := make([]string, 0, len(vals))
	for _, v := range vals {
		s, ok := v.(string)
		if !ok {
			s = fmt.Sprint(v)
		}
		ss = append(ss, s)
	}
	return stringSliceCursor("name", ss, int64(len(ss))), nil
}

func gomongoScalarRowsCursor(vals []any) (rowCursor, error) {
	rows := make([][]dbQueryValue, 0, len(vals))
	for _, v := range vals {
		rows = append(rows, []dbQueryValue{buildQueryValue(v)})
	}
	return &mongoMemCur{
		header: &dbQueryHeader{
			columns:      []dbQueryColumn{{name: "value", dataType: dataTypeChar}},
			affectedRows: int64(len(rows)),
		},
		rows: rows,
	}, nil
}

func gomongoResultDocCursor(vals []any) (rowCursor, error) {
	if len(vals) == 0 {
		return singleValueCursor("ok", 1, 0), nil
	}
	cell, err := mongoValueToJSONCell(vals[0])
	if err != nil {
		return nil, err
	}
	return singleRowJSONCursor("result", cell, 1), nil
}

func gomongoSingleValueRow(v interface{}) ([]dbQueryValue, error) {
	cell, err := mongoValueToJSONCell(v)
	if err != nil {
		return nil, err
	}
	return []dbQueryValue{cell}, nil
}

func mongoValueToJSONCell(v interface{}) (dbQueryValue, error) {
	switch x := v.(type) {
	case bson.D:
		b, err := bson.Marshal(x)
		if err != nil {
			return dbQueryValue{}, err
		}
		return bsonRawToJSONCell(bson.Raw(b))
	case bson.M:
		b, err := bson.Marshal(x)
		if err != nil {
			return dbQueryValue{}, err
		}
		return bsonRawToJSONCell(bson.Raw(b))
	case bson.Raw:
		return bsonRawToJSONCell(x)
	default:
		b, err := bson.Marshal(x)
		if err != nil {
			return dbQueryValue{valueType: goImplQueryValueString, bytesValue: []byte(fmt.Sprint(x))}, nil
		}
		return bsonRawToJSONCell(bson.Raw(b))
	}
}
