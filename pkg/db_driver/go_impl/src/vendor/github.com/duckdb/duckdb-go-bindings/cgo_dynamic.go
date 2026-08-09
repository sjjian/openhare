//go:build duckdb_use_lib

package duckdb_go_bindings

/*
#cgo CPPFLAGS: -I${SRCDIR}/include
#cgo LDFLAGS: -lduckdb
#include <duckdb.h>
*/
import "C"
