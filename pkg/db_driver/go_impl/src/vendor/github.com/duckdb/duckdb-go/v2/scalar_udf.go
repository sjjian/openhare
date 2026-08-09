package duckdb

/*
void scalar_udf_callback(void *, void *, void *);
typedef void (*scalar_udf_callback_t)(void *, void *, void *);

void scalar_udf_delete_callback(void *);
typedef void (*scalar_udf_delete_callback_t)(void *);

void *scalar_udf_bind_copy_callback(void *);
typedef void *(*scalar_udf_bind_copy_callback_t)(void *);

void scalar_udf_bind_callback(void *);
typedef void (*scalar_udf_bind_callback_t)(void *);
*/
import "C"

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"runtime"
	"runtime/cgo"
	"unsafe"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

// ScalarFuncConfig contains the fields to configure a user-defined scalar function.
type ScalarFuncConfig struct {
	// InputTypeInfos contains Type information for each input parameter of the scalar function.
	InputTypeInfos []TypeInfo
	// ResultTypeInfo holds the Type information of the scalar function's result type.
	ResultTypeInfo TypeInfo

	// VariadicTypeInfo configures the number of input parameters.
	// If this field is nil, then the input parameters match InputTypeInfos.
	// Otherwise, the scalar function's input parameters are set to variadic, allowing any number of input parameters.
	// The Type of the first len(InputTypeInfos) parameters is configured by InputTypeInfos, and all
	// remaining parameters must match the variadic Type. To configure different variadic parameter types,
	// you must set the VariadicTypeInfo's Type to TYPE_ANY.
	VariadicTypeInfo TypeInfo
	// Volatile sets the stability of the scalar function to volatile, if true.
	// Volatile scalar functions might create a different result per row.
	// E.g., random() is a volatile scalar function.
	Volatile bool
	// SpecialNullHandling disables the default NULL handling of scalar functions, if true.
	// The default NULL handling is: NULL in, NULL out. I.e., if any input parameter is NULL, then the result is NULL.
	SpecialNullHandling bool
}

// bindData holds bind data accessible during execution.
type bindData struct {
	connId uint64
	// We ignore the linter because we need to pass the context through C memory.
	ctx context.Context //nolint:containedctx
}

// ScalarUDFArg contains scalar UDF argument metadata and the optional argument.
type ScalarUDFArg struct {
	// Foldable is true, if the argument was folded into a value, else false.
	Foldable bool
	// Value is the folded argument value, or nil, if the argument is not foldable.
	Value driver.Value
}

type (
	// RowExecutorFn is the type for any row-based execution function.
	// It takes the row values and returns the row execution result, or error.
	RowExecutorFn func(values []driver.Value) (any, error)
	// RowContextExecutorFn accepts a row-based execution function using a context.
	// It takes a context and the row values, and returns the row execution result, or error.
	RowContextExecutorFn func(ctx context.Context, values []driver.Value) (any, error)
	// ChunkContextExecutorFn accepts a chunk-based execution function using a context.
	// It takes a context and the chunk-batched input, and sets the execution result for that chunk.
	// FIXME: It currently still operates row-by-row within one callback, meaning that it still fetches each row
	// FIXME: via GetValue per column, and the result is also set on a per-row basis.
	// FIXME: A genuinely vectorized API requires additional work on the data chunk setter and getter interfaces.
	ChunkContextExecutorFn func(ctx context.Context, chunk *ChunkIteratorState) error
	// ScalarBinderFn takes a (parent) context and the scalar function's arguments.
	// It returns the possibly updated child context (can be the same as the parent).
	// The child context can contain additional arbitrary data available during execution.
	// Please ensure correct context inheritance.
	ScalarBinderFn func(parentCtx context.Context, args []ScalarUDFArg) (context.Context, error)
)

// ScalarFuncExecutor contains the functions to execute a user-defined scalar function.
// It invokes its first non-nil member.
type ScalarFuncExecutor struct {
	// RowExecutor accepts a row-based execution function of type RowExecutorFn.
	RowExecutor RowExecutorFn
	// RowContextExecutor accepts a row-based execution function of type RowContextExecutorFn.
	RowContextExecutor RowContextExecutorFn
	// ChunkContextExecutor accepts a chunk-based execution function of type ChunkContextExecutorFn.
	ChunkContextExecutor ChunkContextExecutorFn
	// Binder accepts a bind function of type ScalarBinderFn.
	ScalarBinder ScalarBinderFn
}

// ScalarFunc is the user-defined scalar function interface.
// Any scalar function must implement a Config function, and an Executor function.
type ScalarFunc interface {
	// Config returns ScalarFuncConfig to configure the scalar function.
	Config() ScalarFuncConfig
	// Executor returns ScalarFuncExecutor to execute the scalar function.
	Executor() ScalarFuncExecutor
}

// scalarFuncContext wraps ScalarFunc and provides an execution context.
type scalarFuncContext struct {
	f        ScalarFunc
	ctxStore *contextStore
}

// Config returns the ScalarFuncConfig of the scalar function.
func (s *scalarFuncContext) Config() ScalarFuncConfig {
	return s.f.Config()
}

// RowExecutor returns a RowExecutorFn executing the scalar function.
// It uses the bindInfo to get the execution context.
func (s *scalarFuncContext) RowExecutor(info *bindData) (RowExecutorFn, error) {
	e := s.f.Executor()
	if e.RowExecutor != nil {
		return e.RowExecutor, nil
	}

	if err := s.setCtx(info); err != nil {
		return nil, err
	}

	return func(values []driver.Value) (any, error) {
		return e.RowContextExecutor(info.ctx, values)
	}, nil
}

func (s *scalarFuncContext) setCtx(info *bindData) error {
	// Parent context cancellation propagates to children,
	// therefore, it is enough to check the child context here.
	if info.ctx == nil {
		// No child context means that there is no custom bind function.
		// Retrieve the parent context from the connection context store.
		info.ctx = s.ctxStore.load(info.connId)
		return nil
	}
	// Return any potential context error.
	// If the error is not nil, then set it in the function info outside of this function.
	return info.ctx.Err()
}

// RegisterScalarUDF registers a user-defined scalar function.
// *sql.Conn is the SQL connection on which to register the scalar function.
// name is the function name, and f is the scalar function's interface ScalarFunc.
// RegisterScalarUDF takes ownership of f, so you must pass it as a pointer.
func RegisterScalarUDF(c *sql.Conn, name string, f ScalarFunc) error {
	function, err := createScalarFunc(c, name, f)
	if err != nil {
		return getError(errAPI, err)
	}
	defer mapping.DestroyScalarFunction(&function)

	// Register the function on the underlying driver connection exposed by c.Raw.
	err = c.Raw(func(driverConn any) error {
		conn := driverConn.(*Conn)
		state := mapping.RegisterScalarFunction(conn.conn, function)
		if state == mapping.StateError {
			return getError(errAPI, errScalarUDFCreate)
		}
		return nil
	})
	return err
}

// RegisterScalarUDFSet registers a set of user-defined scalar functions with the same name.
// This enables overloading of scalar functions.
// E.g., the function my_length() can have implementations like my_length(LIST(ANY)) and my_length(VARCHAR).
// *sql.Conn is the SQL connection on which to register the scalar function set.
// name is the function name of each function in the set.
// functions contains all ScalarFunc functions of the scalar function set.
func RegisterScalarUDFSet(c *sql.Conn, name string, functions ...ScalarFunc) error {
	set := mapping.CreateScalarFunctionSet(name)

	// Create each function and add it to the set.
	for i, f := range functions {
		function, err := createScalarFunc(c, name, f)
		if err != nil {
			mapping.DestroyScalarFunctionSet(&set)
			return getError(errAPI, err)
		}

		state := mapping.AddScalarFunctionToSet(set, function)
		mapping.DestroyScalarFunction(&function)
		if state == mapping.StateError {
			mapping.DestroyScalarFunctionSet(&set)
			return getError(errAPI, addIndexToError(errScalarUDFAddToSet, i))
		}
	}

	// Register the function set on the underlying driver connection exposed by c.Raw.
	err := c.Raw(func(driverConn any) error {
		conn := driverConn.(*Conn)
		state := mapping.RegisterScalarFunctionSet(conn.conn, set)
		mapping.DestroyScalarFunctionSet(&set)
		if state == mapping.StateError {
			return getError(errAPI, errScalarUDFCreateSet)
		}
		return nil
	})
	return err
}

//export scalar_udf_callback
func scalar_udf_callback(functionInfoPtr, inputPtr, outputPtr unsafe.Pointer) {
	functionInfo := mapping.FunctionInfo{Ptr: functionInfoPtr}
	input := mapping.DataChunk{Ptr: inputPtr}
	output := mapping.Vector{Ptr: outputPtr}

	// Initialize the input chunk.
	var inputChunk DataChunk
	if err := inputChunk.initFromDuckDataChunk(input, false); err != nil {
		mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
		return
	}

	// Initialize the output chunk.
	var outputChunk DataChunk
	if err := outputChunk.initFromDuckVector(output, true); err != nil {
		mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
		return
	}

	extraInfo := mapping.ScalarFunctionGetExtraInfo(functionInfo)
	funcCtx := getPinned[*scalarFuncContext](extraInfo)
	nullInNullOut := !funcCtx.Config().SpecialNullHandling

	bindDataPtr := mapping.ScalarFunctionGetBindData(functionInfo)
	pinnedBindData := getPinned[*bindData](bindDataPtr)

	// Check if using chunk executor.
	executor := funcCtx.f.Executor()
	if executor.ChunkContextExecutor != nil {
		executeChunk(funcCtx, pinnedBindData, &inputChunk, &outputChunk, functionInfo, nullInNullOut)
		return
	}

	// Prepare the values.
	length := len(inputChunk.columns)
	values := make([]driver.Value, length)

	// Execute the user-defined scalar function for each row.
	f, err := funcCtx.RowExecutor(pinnedBindData)
	if err != nil {
		mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
		return
	}

	for rowIdx := range inputChunk.GetSize() {
		// Get each column value.
		nullRow := false
		for colIdx := range length {
			if values[colIdx], err = inputChunk.GetValue(colIdx, rowIdx); err != nil {
				mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
				return
			}

			// NULL handling.
			if nullInNullOut && values[colIdx] == nil {
				if err = outputChunk.SetValue(0, rowIdx, nil); err != nil {
					mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
					return
				}
				nullRow = true
				break
			}
		}

		if nullRow {
			continue
		}

		// Execute the user-defined scalar function.
		if val, e := f(values); e != nil {
			mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, e).Error())
			return
		} else {
			// Write the result to the output chunk.
			if err = outputChunk.SetValue(0, rowIdx, val); err != nil {
				mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
				return
			}
		}
	}
}

// executeChunk handles chunk-based execution of scalar UDFs.
func executeChunk(funcCtx *scalarFuncContext, bindInfo *bindData,
	inputChunk, outputChunk *DataChunk,
	functionInfo mapping.FunctionInfo, nullInNullOut bool,
) {
	// Set the context.
	if err := funcCtx.setCtx(bindInfo); err != nil {
		mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
		return
	}

	// Create chunk wrapper.
	// When nullInNullOut is enabled, the Rows() iterator automatically skips
	// rows with NULL inputs and sets their result to NULL.
	chunk := &ChunkIteratorState{
		r: Row{
			chunk:  inputChunk,
			rowIdx: mapping.IdxT(0),
		},
		output:        &outputChunk.columns[0],
		nullInNullOut: nullInNullOut,
		args:          make([]driver.Value, inputChunk.ColumnCount()),
	}

	// Execute - user iterates over rows, each row has pre-fetched Args.
	if err := funcCtx.f.Executor().ChunkContextExecutor(bindInfo.ctx, chunk); err != nil {
		mapping.ScalarFunctionSetError(functionInfo, getError(errAPI, err).Error())
		return
	}
}

//export scalar_udf_delete_callback
func scalar_udf_delete_callback(info unsafe.Pointer) {
	h := (*cgo.Handle)(info)
	h.Value().(unpinner).unpin()
	h.Delete()
}

//export scalar_udf_bind_copy_callback
func scalar_udf_bind_copy_callback(dataPtr unsafe.Pointer) unsafe.Pointer {
	// Copy and pin the bind data.
	data := getPinned[*bindData](dataPtr)
	dataCopy := *data

	value := pinnedValue[*bindData]{
		pinner: &runtime.Pinner{},
		value:  &dataCopy,
	}
	h := cgo.NewHandle(value)
	value.pinner.Pin(&h)

	return unsafe.Pointer(&h)
}

//export scalar_udf_bind_callback
func scalar_udf_bind_callback(bindInfoPtr unsafe.Pointer) {
	bindInfo := mapping.BindInfo{Ptr: bindInfoPtr}

	var clientCtx mapping.ClientContext
	mapping.ScalarFunctionGetClientContext(bindInfo, &clientCtx)
	defer mapping.DestroyClientContext(&clientCtx)

	// We need the connId to retrieve the correct parent context.
	// Then, we store the child context in data.
	connId := mapping.ClientContextGetConnectionId(clientCtx)
	data := bindData{connId: uint64(connId)}

	extraInfo := mapping.ScalarFunctionBindGetExtraInfo(bindInfo)
	funcCtx := getPinned[*scalarFuncContext](extraInfo)

	// Get any custom bind data by invoking the custom bind function.
	if funcCtx.f.Executor().ScalarBinder != nil {
		bindCtx, err := funcCtx.bind(clientCtx, bindInfo, uint64(connId))
		if err != nil {
			mapping.ScalarFunctionBindSetError(bindInfo, err.Error())
			return
		}
		data.ctx = bindCtx
	}

	// Set the copy callback of the bind info.
	copyPtr := unsafe.Pointer(C.scalar_udf_bind_copy_callback_t(C.scalar_udf_bind_copy_callback))
	mapping.ScalarFunctionSetBindDataCopy(bindInfo, copyPtr)

	// Pin the bind data.
	value := pinnedValue[*bindData]{
		pinner: &runtime.Pinner{},
		value:  &data,
	}
	h := cgo.NewHandle(value)
	value.pinner.Pin(&h)

	// Set the bind data.
	deleteCallbackPtr := unsafe.Pointer(C.scalar_udf_delete_callback_t(C.scalar_udf_delete_callback))
	mapping.ScalarFunctionSetBindData(bindInfo, unsafe.Pointer(&h), deleteCallbackPtr)
}

func getScalarUDFArg(clientCtx mapping.ClientContext, bindInfo mapping.BindInfo, index int) (ScalarUDFArg, error) {
	expr := mapping.ScalarFunctionBindGetArgument(bindInfo, mapping.IdxT(index))
	defer mapping.DestroyExpression(&expr)

	arg := ScalarUDFArg{
		Foldable: mapping.ExpressionIsFoldable(expr),
	}
	if !arg.Foldable {
		return arg, nil
	}

	// Fold the argument.
	var v mapping.Value
	errorData := mapping.ExpressionFold(clientCtx, expr, &v)
	defer mapping.DestroyValue(&v)
	err := errorDataError(errorData)
	if err != nil {
		return arg, err
	}

	// Get the mapping.Value as a driver.Value and return.
	arg.Value, err = getValue(v)
	if err != nil {
		return arg, err
	}
	return arg, nil
}

func (s *scalarFuncContext) bind(clientCtx mapping.ClientContext, bindInfo mapping.BindInfo, connId uint64) (context.Context, error) {
	ctx := s.ctxStore.load(connId)
	argCount := mapping.ScalarFunctionBindGetArgumentCount(bindInfo)

	var args []ScalarUDFArg
	for i := range int(argCount) {
		arg, err := getScalarUDFArg(clientCtx, bindInfo, i)
		if err != nil {
			return nil, err
		}
		args = append(args, arg)
	}

	bindCtx, err := s.f.Executor().ScalarBinder(ctx, args)
	if err != nil {
		return nil, err
	}

	// Propagate the parent context, if the child context is nil.
	if ctx != nil && bindCtx == nil {
		bindCtx = ctx
	}

	return bindCtx, nil
}

func registerInputParams(config ScalarFuncConfig, f mapping.ScalarFunction) error {
	// Set variadic input parameters.
	if config.VariadicTypeInfo != nil {
		t := config.VariadicTypeInfo.logicalType()
		mapping.ScalarFunctionSetVarargs(f, t)
		mapping.DestroyLogicalType(&t)
	}

	// Early-out, if the function does not take any (non-variadic) parameters.
	if config.InputTypeInfos == nil {
		return nil
	}
	if len(config.InputTypeInfos) == 0 {
		return nil
	}

	// Set non-variadic input parameters.
	for i, info := range config.InputTypeInfos {
		if info == nil {
			return addIndexToError(errScalarUDFInputTypeIsNil, i)
		}
		t := info.logicalType()
		mapping.ScalarFunctionAddParameter(f, t)
		mapping.DestroyLogicalType(&t)
	}
	return nil
}

func registerResultParams(config ScalarFuncConfig, f mapping.ScalarFunction) error {
	if config.ResultTypeInfo == nil {
		return errScalarUDFResultTypeIsNil
	}
	if config.ResultTypeInfo.InternalType() == TYPE_ANY {
		return errScalarUDFResultTypeIsANY
	}
	t := config.ResultTypeInfo.logicalType()
	mapping.ScalarFunctionSetReturnType(f, t)
	mapping.DestroyLogicalType(&t)
	return nil
}

func createScalarFunc(c *sql.Conn, name string, f ScalarFunc) (mapping.ScalarFunction, error) {
	if name == "" {
		return mapping.ScalarFunction{}, errScalarUDFNoName
	}
	if f == nil {
		return mapping.ScalarFunction{}, errScalarUDFIsNil
	}

	if f.Executor().RowExecutor == nil && f.Executor().RowContextExecutor == nil && f.Executor().ChunkContextExecutor == nil {
		return mapping.ScalarFunction{}, errScalarUDFNoExecutor
	}

	function := mapping.CreateScalarFunction()
	mapping.ScalarFunctionSetName(function, name)

	// Configure the scalar function.
	config := f.Config()
	if err := registerInputParams(config, function); err != nil {
		mapping.DestroyScalarFunction(&function)
		return function, err
	}
	if err := registerResultParams(config, function); err != nil {
		mapping.DestroyScalarFunction(&function)
		return function, err
	}
	if config.SpecialNullHandling {
		mapping.ScalarFunctionSetSpecialHandling(function)
	}
	if config.Volatile {
		mapping.ScalarFunctionSetVolatile(function)
	}

	// Set the bind callback.
	bindPtr := unsafe.Pointer(C.scalar_udf_bind_callback_t(C.scalar_udf_bind_callback))
	mapping.ScalarFunctionSetBind(function, bindPtr)

	// Set the function callback.
	functionPtr := unsafe.Pointer(C.scalar_udf_callback_t(C.scalar_udf_callback))
	mapping.ScalarFunctionSetFunction(function, functionPtr)

	// Get the context store of the connection.
	ctxStore, err := contextStoreFromConn(c)
	if err != nil {
		mapping.DestroyScalarFunction(&function)
		return function, err
	}

	// Pin the ScalarFunc f.
	value := pinnedValue[*scalarFuncContext]{
		pinner: &runtime.Pinner{},
		value:  &scalarFuncContext{f: f, ctxStore: ctxStore},
	}
	h := cgo.NewHandle(value)
	value.pinner.Pin(&h)

	// Set the execution data, which is the ScalarFunc f.
	deleteCallbackPtr := unsafe.Pointer(C.scalar_udf_delete_callback_t(C.scalar_udf_delete_callback))
	mapping.ScalarFunctionSetExtraInfo(function, unsafe.Pointer(&h), deleteCallbackPtr)
	return function, nil
}
