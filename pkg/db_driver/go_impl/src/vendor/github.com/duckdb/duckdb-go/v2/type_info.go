package duckdb

import (
	"errors"
	"reflect"
	"runtime"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

type structEntry struct {
	TypeInfo

	name string
}

// StructEntry is an interface to provide STRUCT entry information.
type StructEntry interface {
	// Info returns a STRUCT entry's type information.
	Info() TypeInfo
	// Name returns a STRUCT entry's name.
	Name() string
}

// NewStructEntry returns a STRUCT entry.
// info contains information about the entry's type, and name holds the entry's name.
func NewStructEntry(info TypeInfo, name string) (StructEntry, error) {
	if name == "" {
		return nil, getError(errAPI, errEmptyName)
	}

	return &structEntry{
		TypeInfo: info,
		name:     name,
	}, nil
}

// Info returns a STRUCT entry's type information.
func (entry *structEntry) Info() TypeInfo {
	return entry.TypeInfo
}

// Name returns a STRUCT entry's name.
func (entry *structEntry) Name() string {
	return entry.name
}

// TypeDetails is an interface for type-specific details.
// Use type assertion to access specific detail types.
type TypeDetails interface {
	isTypeDetails()
}

// DecimalDetails provides DECIMAL type information.
type DecimalDetails struct {
	Width uint8
	Scale uint8
}

func (d *DecimalDetails) isTypeDetails() {}

// EnumDetails provides ENUM type information.
type EnumDetails struct {
	Values []string
}

func (e *EnumDetails) isTypeDetails() {}

// ListDetails provides LIST type information.
type ListDetails struct {
	Child TypeInfo
}

func (l *ListDetails) isTypeDetails() {}

// ArrayDetails provides ARRAY type information.
type ArrayDetails struct {
	Child TypeInfo
	Size  uint64
}

func (a *ArrayDetails) isTypeDetails() {}

// MapDetails provides MAP type information.
type MapDetails struct {
	Key   TypeInfo
	Value TypeInfo
}

func (m *MapDetails) isTypeDetails() {}

// StructDetails provides STRUCT type information.
type StructDetails struct {
	Entries []StructEntry
}

func (s *StructDetails) isTypeDetails() {}

// UnionMember represents a UNION member with its name and type.
type UnionMember struct {
	Name string
	Type TypeInfo
}

// UnionDetails provides UNION type information.
type UnionDetails struct {
	Members []UnionMember
}

func (u *UnionDetails) isTypeDetails() {}

type baseTypeInfo struct {
	Type

	structEntries []StructEntry
	decimalWidth  uint8
	decimalScale  uint8
	arrayLength   mapping.IdxT
	// The internal type for ENUM and DECIMAL values.
	internalType Type
}

type vectorTypeInfo struct {
	baseTypeInfo

	namesDict map[string]uint32
	tagDict   map[uint32]string
	// enumDict is the reverse of namesDict for ENUM types (index → name).
	// Uses a slice instead of a map because enum indices are dense integers starting at 0,
	// making indexing faster than map hashing.
	enumDict []string
}

type typeInfo struct {
	baseTypeInfo

	// Member or child types for LIST, MAP, ARRAY, and UNION.
	types []TypeInfo
	// Enum names or UNION member names.
	names []string
}

// TypeInfo is an interface for a DuckDB type.
type TypeInfo interface {
	// InternalType returns the Type.
	InternalType() Type
	// Details returns type-specific details for complex types.
	// Returns nil for simple/primitive types.
	// Use type assertion to access specific detail types.
	Details() TypeDetails
	logicalType() mapping.LogicalType
}

func (info *typeInfo) InternalType() Type {
	return info.Type
}

// Details returns type-specific details for complex types.
// Returns nil for simple/primitive types.
func (info *typeInfo) Details() TypeDetails {
	switch info.Type {
	case TYPE_DECIMAL:
		return &DecimalDetails{
			Width: info.decimalWidth,
			Scale: info.decimalScale,
		}
	case TYPE_ENUM:
		// Make a copy of the slice to avoid exposing internal state
		values := make([]string, len(info.names))
		copy(values, info.names)
		return &EnumDetails{
			Values: values,
		}
	case TYPE_LIST:
		return &ListDetails{
			Child: info.types[0],
		}
	case TYPE_ARRAY:
		return &ArrayDetails{
			Child: info.types[0],
			Size:  uint64(info.arrayLength),
		}
	case TYPE_MAP:
		return &MapDetails{
			Key:   info.types[0],
			Value: info.types[1],
		}
	case TYPE_STRUCT:
		// Make a copy of the slice to avoid exposing internal state
		entries := make([]StructEntry, len(info.structEntries))
		copy(entries, info.structEntries)
		return &StructDetails{
			Entries: entries,
		}
	case TYPE_UNION:
		// Build UnionMembers from types and names
		members := make([]UnionMember, len(info.types))
		for i := range info.types {
			members[i] = UnionMember{
				Name: info.names[i],
				Type: info.types[i],
			}
		}
		return &UnionDetails{
			Members: members,
		}
	default:
		return nil
	}
}

// NewTypeInfo returns type information for DuckDB's primitive types.
// It returns the TypeInfo, if the Type parameter is a valid primitive type.
// Else, it returns nil, and an error.
// Valid types are:
// TYPE_[BOOLEAN, TINYINT, SMALLINT, INTEGER, BIGINT, UTINYINT, USMALLINT, UINTEGER,
// UBIGINT, FLOAT, DOUBLE, TIMESTAMP, DATE, TIME, INTERVAL, HUGEINT, UHUGEINT, VARCHAR,
// BLOB, BIT, TIMESTAMP_S, TIMESTAMP_MS, TIMESTAMP_NS, UUID, TIMESTAMP_TZ, VARIANT, ANY].
func NewTypeInfo(t Type) (TypeInfo, error) {
	name, inMap := unsupportedTypeToStringMap[t]
	if inMap && t != TYPE_ANY {
		return nil, getError(errAPI, unsupportedTypeError(name))
	}

	switch t {
	case TYPE_DECIMAL:
		return nil, getError(errAPI, tryOtherFuncError(funcName(NewDecimalInfo)))
	case TYPE_ENUM:
		return nil, getError(errAPI, tryOtherFuncError(funcName(NewEnumInfo)))
	case TYPE_LIST:
		return nil, getError(errAPI, tryOtherFuncError(funcName(NewListInfo)))
	case TYPE_STRUCT:
		return nil, getError(errAPI, tryOtherFuncError(funcName(NewStructInfo)))
	case TYPE_MAP:
		return nil, getError(errAPI, tryOtherFuncError(funcName(NewMapInfo)))
	case TYPE_ARRAY:
		return nil, getError(errAPI, tryOtherFuncError(funcName(NewArrayInfo)))
	case TYPE_UNION:
		return nil, getError(errAPI, tryOtherFuncError(funcName(NewUnionInfo)))
	case TYPE_SQLNULL:
		return nil, getError(errAPI, unsupportedTypeError(typeToStringMap[t]))
	}

	return &typeInfo{
		baseTypeInfo: baseTypeInfo{Type: t},
	}, nil
}

// NewDecimalInfo returns DECIMAL type information.
// Its input parameters are the width and scale of the DECIMAL type.
func NewDecimalInfo(width, scale uint8) (TypeInfo, error) {
	if width < 1 || width > max_decimal_width {
		return nil, getError(errAPI, errInvalidDecimalWidth)
	}
	if scale > width {
		return nil, getError(errAPI, errInvalidDecimalScale)
	}

	return &typeInfo{
		baseTypeInfo: baseTypeInfo{
			Type:         TYPE_DECIMAL,
			decimalWidth: width,
			decimalScale: scale,
		},
	}, nil
}

// NewEnumInfo returns ENUM type information.
// Its input parameters are the dictionary values.
func NewEnumInfo(first string, others ...string) (TypeInfo, error) {
	// Check for duplicate names.
	m := map[string]bool{}
	m[first] = true
	for _, name := range others {
		_, inMap := m[name]
		if inMap {
			return nil, getError(errAPI, duplicateNameError(name))
		}
		m[name] = true
	}

	info := &typeInfo{
		baseTypeInfo: baseTypeInfo{
			Type: TYPE_ENUM,
		},
		names: make([]string, 0),
	}

	info.names = append(info.names, first)
	info.names = append(info.names, others...)
	return info, nil
}

// NewListInfo returns LIST type information.
// childInfo contains the type information of the LIST's elements.
func NewListInfo(childInfo TypeInfo) (TypeInfo, error) {
	if childInfo == nil {
		return nil, getError(errAPI, interfaceIsNilError("childInfo"))
	}

	info := &typeInfo{
		baseTypeInfo: baseTypeInfo{Type: TYPE_LIST},
		types:        make([]TypeInfo, 1),
	}
	info.types[0] = childInfo
	return info, nil
}

// NewStructInfo returns STRUCT type information.
// Its input parameters are the STRUCT entries.
func NewStructInfo(firstEntry StructEntry, others ...StructEntry) (TypeInfo, error) {
	if firstEntry == nil {
		return nil, getError(errAPI, interfaceIsNilError("firstEntry"))
	}
	if firstEntry.Info() == nil {
		return nil, getError(errAPI, interfaceIsNilError("firstEntry.Info()"))
	}
	for i, entry := range others {
		if entry == nil {
			return nil, getError(errAPI, addIndexToError(interfaceIsNilError("entry"), i))
		}
		if entry.Info() == nil {
			return nil, getError(errAPI, addIndexToError(interfaceIsNilError("entry.Info()"), i))
		}
	}

	// Check for duplicate names.
	m := map[string]bool{}
	m[firstEntry.Name()] = true
	for _, entry := range others {
		name := entry.Name()
		_, inMap := m[name]
		if inMap {
			return nil, getError(errAPI, duplicateNameError(name))
		}
		m[name] = true
	}

	info := &typeInfo{
		baseTypeInfo: baseTypeInfo{
			Type:          TYPE_STRUCT,
			structEntries: make([]StructEntry, 0),
		},
	}
	info.structEntries = append(info.structEntries, firstEntry)
	info.structEntries = append(info.structEntries, others...)
	return info, nil
}

// NewMapInfo returns MAP type information.
// keyInfo contains the type information of the MAP keys.
// valueInfo contains the type information of the MAP values.
func NewMapInfo(keyInfo, valueInfo TypeInfo) (TypeInfo, error) {
	if keyInfo == nil {
		return nil, getError(errAPI, interfaceIsNilError("keyInfo"))
	}
	if valueInfo == nil {
		return nil, getError(errAPI, interfaceIsNilError("valueInfo"))
	}

	info := &typeInfo{
		baseTypeInfo: baseTypeInfo{Type: TYPE_MAP},
		types:        make([]TypeInfo, 2),
	}
	info.types[0] = keyInfo
	info.types[1] = valueInfo
	return info, nil
}

// NewArrayInfo returns ARRAY type information.
// childInfo contains the type information of the ARRAY's elements.
// size is the ARRAY's fixed size.
func NewArrayInfo(childInfo TypeInfo, size uint64) (TypeInfo, error) {
	if childInfo == nil {
		return nil, getError(errAPI, interfaceIsNilError("childInfo"))
	}
	if size == 0 {
		return nil, getError(errAPI, errInvalidArraySize)
	}

	info := &typeInfo{
		baseTypeInfo: baseTypeInfo{Type: TYPE_ARRAY, arrayLength: mapping.IdxT(size)},
		types:        make([]TypeInfo, 1),
	}
	info.types[0] = childInfo
	return info, nil
}

// NewUnionInfo returns UNION type information.
// memberTypes contains the type information of the union members.
// memberNames contains the names of the union members.
func NewUnionInfo(memberTypes []TypeInfo, memberNames []string) (TypeInfo, error) {
	if len(memberTypes) == 0 {
		return nil, getError(errAPI, errors.New("UNION type must have at least one member"))
	}
	if len(memberTypes) != len(memberNames) {
		return nil, getError(errAPI, errors.New("member types and names must have the same length"))
	}

	// Check for duplicate names.
	m := map[string]bool{}
	for _, name := range memberNames {
		if name == "" {
			return nil, getError(errAPI, errEmptyName)
		}
		if m[name] {
			return nil, getError(errAPI, duplicateNameError(name))
		}
		m[name] = true
	}

	info := &typeInfo{
		baseTypeInfo: baseTypeInfo{Type: TYPE_UNION},
		types:        memberTypes,
		names:        memberNames,
	}
	return info, nil
}

func (info *typeInfo) logicalType() mapping.LogicalType {
	switch info.Type {
	case TYPE_BOOLEAN, TYPE_TINYINT, TYPE_SMALLINT, TYPE_INTEGER, TYPE_BIGINT, TYPE_UTINYINT, TYPE_USMALLINT,
		TYPE_UINTEGER, TYPE_UBIGINT, TYPE_FLOAT, TYPE_DOUBLE, TYPE_TIMESTAMP, TYPE_TIMESTAMP_S, TYPE_TIMESTAMP_MS,
		TYPE_TIMESTAMP_NS, TYPE_TIMESTAMP_TZ, TYPE_DATE, TYPE_TIME, TYPE_TIME_TZ, TYPE_INTERVAL, TYPE_HUGEINT,
		TYPE_UHUGEINT, TYPE_VARCHAR, TYPE_BLOB, TYPE_BIT, TYPE_GEOMETRY, TYPE_UUID, TYPE_VARIANT, TYPE_ANY:
		return mapping.CreateLogicalType(info.Type)
	case TYPE_DECIMAL:
		return mapping.CreateDecimalType(info.decimalWidth, info.decimalScale)
	case TYPE_ENUM:
		return mapping.CreateEnumType(info.names)
	case TYPE_LIST:
		return info.logicalListType()
	case TYPE_STRUCT:
		return info.logicalStructType()
	case TYPE_MAP:
		return info.logicalMapType()
	case TYPE_ARRAY:
		return info.logicalArrayType()
	case TYPE_UNION:
		return info.logicalUnionType()
	}
	return mapping.LogicalType{}
}

func (info *typeInfo) logicalListType() mapping.LogicalType {
	child := info.types[0].logicalType()
	defer mapping.DestroyLogicalType(&child)
	return mapping.CreateListType(child)
}

func (info *typeInfo) logicalStructType() mapping.LogicalType {
	var types []mapping.LogicalType
	defer func() { destroyLogicalTypes(types) }()

	var names []string
	for _, entry := range info.structEntries {
		types = append(types, entry.Info().logicalType())
		names = append(names, entry.Name())
	}
	return mapping.CreateStructType(types, names)
}

func (info *typeInfo) logicalMapType() mapping.LogicalType {
	key := info.types[0].logicalType()
	defer mapping.DestroyLogicalType(&key)
	value := info.types[1].logicalType()
	defer mapping.DestroyLogicalType(&value)
	return mapping.CreateMapType(key, value)
}

func (info *typeInfo) logicalArrayType() mapping.LogicalType {
	child := info.types[0].logicalType()
	defer mapping.DestroyLogicalType(&child)
	return mapping.CreateArrayType(child, info.arrayLength)
}

func (info *typeInfo) logicalUnionType() mapping.LogicalType {
	var types []mapping.LogicalType
	defer func() { destroyLogicalTypes(types) }()
	for _, t := range info.types {
		types = append(types, t.logicalType())
	}
	return mapping.CreateUnionType(types, info.names)
}

// newTypeInfoFromLogicalType converts a mapping.LogicalType to TypeInfo.
// This allows inspecting types returned from prepared statements.
// The LogicalType must remain valid for the duration of this call.
// The returned TypeInfo does not hold a reference to the LogicalType.
func newTypeInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	t := mapping.GetTypeId(lt)

	switch t {
	case TYPE_DECIMAL:
		return newDecimalInfoFromLogicalType(lt)
	case TYPE_ENUM:
		return newEnumInfoFromLogicalType(lt)
	case TYPE_LIST:
		return newListInfoFromLogicalType(lt)
	case TYPE_ARRAY:
		return newArrayInfoFromLogicalType(lt)
	case TYPE_MAP:
		return newMapInfoFromLogicalType(lt)
	case TYPE_STRUCT:
		return newStructInfoFromLogicalType(lt)
	case TYPE_UNION:
		return newUnionInfoFromLogicalType(lt)
	default:
		// Simple/primitive type
		return NewTypeInfo(t)
	}
}

func newDecimalInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	width := mapping.DecimalWidth(lt)
	scale := mapping.DecimalScale(lt)
	return NewDecimalInfo(width, scale)
}

func newEnumInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	size := mapping.EnumDictionarySize(lt)
	if size == 0 {
		return nil, getError(errAPI, errors.New("ENUM type must have at least one value"))
	}

	values := make([]string, size)
	for i := range size {
		values[i] = mapping.EnumDictionaryValue(lt, mapping.IdxT(i))
	}

	return NewEnumInfo(values[0], values[1:]...)
}

func newListInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	childLT := mapping.ListTypeChildType(lt)
	defer mapping.DestroyLogicalType(&childLT)

	childInfo, err := newTypeInfoFromLogicalType(childLT)
	if err != nil {
		return nil, err
	}

	return NewListInfo(childInfo)
}

func newArrayInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	childLT := mapping.ArrayTypeChildType(lt)
	defer mapping.DestroyLogicalType(&childLT)

	childInfo, err := newTypeInfoFromLogicalType(childLT)
	if err != nil {
		return nil, err
	}

	size := mapping.ArrayTypeArraySize(lt)
	return NewArrayInfo(childInfo, uint64(size))
}

func newMapInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	keyLT := mapping.MapTypeKeyType(lt)
	defer mapping.DestroyLogicalType(&keyLT)

	valueLT := mapping.MapTypeValueType(lt)
	defer mapping.DestroyLogicalType(&valueLT)

	keyInfo, err := newTypeInfoFromLogicalType(keyLT)
	if err != nil {
		return nil, err
	}

	valueInfo, err := newTypeInfoFromLogicalType(valueLT)
	if err != nil {
		return nil, err
	}

	return NewMapInfo(keyInfo, valueInfo)
}

func newStructInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	count := mapping.StructTypeChildCount(lt)
	if count == 0 {
		return nil, getError(errAPI, errors.New("STRUCT type must have at least one field"))
	}

	entries := make([]StructEntry, count)
	for i := range int(count) {
		name := mapping.StructTypeChildName(lt, mapping.IdxT(i))
		childLT := mapping.StructTypeChildType(lt, mapping.IdxT(i))

		childInfo, err := newTypeInfoFromLogicalType(childLT)
		mapping.DestroyLogicalType(&childLT)
		if err != nil {
			return nil, err
		}

		entry, err := NewStructEntry(childInfo, name)
		if err != nil {
			return nil, err
		}
		entries[i] = entry
	}

	return NewStructInfo(entries[0], entries[1:]...)
}

func newUnionInfoFromLogicalType(lt mapping.LogicalType) (TypeInfo, error) {
	count := mapping.UnionTypeMemberCount(lt)
	if count == 0 {
		return nil, getError(errAPI, errors.New("UNION type must have at least one member"))
	}

	memberTypes := make([]TypeInfo, count)
	memberNames := make([]string, count)

	for i := range int(count) {
		memberNames[i] = mapping.UnionTypeMemberName(lt, mapping.IdxT(i))
		memberLT := mapping.UnionTypeMemberType(lt, mapping.IdxT(i))

		memberInfo, err := newTypeInfoFromLogicalType(memberLT)
		mapping.DestroyLogicalType(&memberLT)
		if err != nil {
			return nil, err
		}
		memberTypes[i] = memberInfo
	}

	return NewUnionInfo(memberTypes, memberNames)
}

func funcName(i any) string {
	return runtime.FuncForPC(reflect.ValueOf(i).Pointer()).Name()
}

func destroyLogicalTypes(types []mapping.LogicalType) {
	for _, t := range types {
		mapping.DestroyLogicalType(&t)
	}
}
