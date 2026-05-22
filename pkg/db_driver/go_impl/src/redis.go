package main

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// normalizeRedisValueForJSON 将 go-redis 返回的 map[interface{}]interface{} 等转为 json.Marshal 可接受的结构。
// encoding/json 不支持 map[interface{}]interface{}（对象键须为 string）。
func normalizeRedisValueForJSON(v interface{}) interface{} {
	if v == nil {
		return nil
	}
	switch x := v.(type) {
	case []interface{}:
		out := make([]interface{}, len(x))
		for i, e := range x {
			out[i] = normalizeRedisValueForJSON(e)
		}
		return out
	case map[string]interface{}:
		out := make(map[string]interface{}, len(x))
		for k, e := range x {
			out[k] = normalizeRedisValueForJSON(e)
		}
		return out
	case map[interface{}]interface{}:
		out := make(map[string]interface{}, len(x))
		for k, e := range x {
			out[redisMapKeyString(k)] = normalizeRedisValueForJSON(e)
		}
		return out
	default:
		// 标量、[]string、[]byte、[]int64 等可直接 json.Marshal；唯独 map[interface{}]interface{} 不行。
		return x
	}
}

func redisMapKeyString(k interface{}) string {
	switch t := k.(type) {
	case string:
		return t
	case []byte:
		return string(t)
	case fmt.Stringer:
		return t.String()
	default:
		return fmt.Sprint(k)
	}
}

// {"cmd":"GET","args":["key"]}，cmd 为命令名，args 为其余参数（传给 redis.Do 时次序为 cmd 后接 args）。
type redisQuery struct {
	Cmd  string   `json:"cmd"`
	Args []string `json:"args"`
}

type redisConn struct {
	client *redis.Client
}

func (c *redisConn) Close() error {
	return c.client.Close()
}

func (c *redisConn) KillQuery() error {
	return nil
}

func (c *redisConn) OpenQuery(sql string) (rowCursor, error) {
	var query redisQuery
	if err := json.Unmarshal([]byte(sql), &query); err != nil {
		return nil, fmt.Errorf(`redis: expect JSON {"cmd":"CMD","args":[...]}: %w`, err)
	}
	ctx := context.Background()
	packed := make([]interface{}, 1+len(query.Args))
	packed[0] = query.Cmd
	for i, a := range query.Args {
		packed[i+1] = a
	}
	raw, err := c.client.Do(ctx, packed...).Result()
	if err != nil {
		return nil, err
	}
	return &redisCur{result: raw}, nil
}

type redisCur struct {
	result interface{} // go-redis Do().Result() 原始值
	idx    int
}

func (q *redisCur) Close() error {
	return nil
}

func (q *redisCur) Header() *dbQueryHeader {
	var aff int64 = 1
	if q.result == nil {
		aff = 0
	}
	return &dbQueryHeader{
		columns:      []dbQueryColumn{{name: "result", dataType: dataTypeJson}},
		affectedRows: aff,
	}
}

func redisResultToCell(v interface{}) dbQueryValue {
	if v == nil {
		return buildQueryValue(nil)
	}
	normalized := normalizeRedisValueForJSON(v)
	b, err := json.Marshal(normalized)
	if err != nil {
		fmt.Println("redisResultToCell error:", err)
		fmt.Println("redisResultToCell value:", v)
		return buildQueryValue(fmt.Sprint(v))
	}
	return buildQueryValue(string(b))
}

func (q *redisCur) NextRow() (*dbQueryRow, bool, error) {
	if q.idx > 0 {
		return nil, false, nil
	}
	q.idx++
	return &dbQueryRow{values: []dbQueryValue{redisResultToCell(q.result)}}, true, nil
}

func openRedisConn(dsn string) (driverConn, error) {
	opt, err := redis.ParseURL(dsn)
	if err != nil {
		return nil, err
	}
	client := redis.NewClient(opt)
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	if err := client.Ping(ctx).Err(); err != nil {
		_ = client.Close()
		return nil, err
	}
	return &redisConn{client: client}, nil
}
