//go:build !duckdb_use_lib && !duckdb_use_static_lib

package duckdb_go_bindings

/*
#cgo CPPFLAGS: -I${SRCDIR}/include -DDUCKDB_STATIC_BUILD

#include <duckdb.h>
*/
import "C"

import _ "github.com/duckdb/duckdb-go-bindings/include"
