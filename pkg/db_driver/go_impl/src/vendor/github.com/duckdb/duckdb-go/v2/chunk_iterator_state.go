package duckdb

import (
	"database/sql/driver"
	"iter"

	"github.com/duckdb/duckdb-go/v2/mapping"
)

// ChunkIteratorState is the chunk-based iterator passed to a ChunkContextExecutorFn.
// It iterates over its rows via Rows().
type ChunkIteratorState struct {
	r             Row
	output        *vector
	nullInNullOut bool
	args          []driver.Value
}

// SetResult sets the current row's output value.
// Call once per yielded row.
func (iterState *ChunkIteratorState) SetResult(val any) error {
	return iterState.output.SetValue(int(iterState.r.rowIdx), val)
}

// GetValuePtr returns a pointer to the current row value for a column.
// Copy the value if you need to, as it is not retained between loop iterations.
func (iterState *ChunkIteratorState) GetValuePtr(colIdx int) *driver.Value {
	return &iterState.args[colIdx]
}

// ColumnCount returns the number of input columns of the iterated chunk.
func (iterState *ChunkIteratorState) ColumnCount() int {
	return len(iterState.args)
}

// Rows is used to iterate over the rows of a data chunk, and to set the result of a
// computation on a row in the output vector.
func (iterState *ChunkIteratorState) Rows() iter.Seq2[*ChunkIteratorState, error] {
	colCount := iterState.r.chunk.ColumnCount()

	return func(yield func(*ChunkIteratorState, error) bool) {
		var err error
		for rowIdx := range iterState.r.chunk.GetSize() {
			hasNull := false
			for colIdx := range colCount {
				// FIXME: Could likely be replaced with a vectorized getter function.
				iterState.args[colIdx], err = iterState.r.chunk.GetValue(colIdx, rowIdx)
				if err != nil {
					yield(nil, err)
					return
				}
				if iterState.args[colIdx] == nil {
					hasNull = true
					if iterState.nullInNullOut {
						break
					}
				}
			}

			if iterState.nullInNullOut && hasNull {
				if err = iterState.output.SetValue(rowIdx, nil); err != nil {
					yield(nil, err)
					return
				}
				continue
			}

			iterState.r.rowIdx = mapping.IdxT(rowIdx)
			if !yield(iterState, nil) {
				return
			}
		}
	}
}
