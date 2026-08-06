//go:build !duckdb_use_lib && !duckdb_use_static_lib && linux && amd64

package duckdb_go_bindings

import _ "github.com/duckdb/duckdb-go-bindings/lib/linux-amd64"
