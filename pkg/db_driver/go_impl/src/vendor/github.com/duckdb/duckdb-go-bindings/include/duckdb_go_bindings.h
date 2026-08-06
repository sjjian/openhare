#include <duckdb.h>

static void duckdb_go_bindings_set_logical_type(duckdb_logical_type *types_ptr, duckdb_logical_type type, idx_t index) {
	types_ptr[index] = type;
}

static void duckdb_go_bindings_set_value(duckdb_value *values_ptr, duckdb_value value, idx_t index) {
	values_ptr[index] = value;
}

static bool duckdb_go_bindings_is_valid(uint64_t *mask_ptr, idx_t index) {
	idx_t entry_idx = index / 64;
	idx_t idx_in_entry = index % 64;
	idx_t base = 1;
	idx_t is_valid = mask_ptr[entry_idx] & (base << idx_in_entry);
	return is_valid != 0;
}