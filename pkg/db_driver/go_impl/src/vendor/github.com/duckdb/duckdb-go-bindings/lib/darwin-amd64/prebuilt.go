//go:build darwin && amd64

package duckdb_go_bindings_platform

/*
#cgo CPPFLAGS: -I${SRCDIR} -DDUCKDB_STATIC_BUILD
#cgo LDFLAGS: -lduckdb_static -lduckdb_generated_extension_loader -lautocomplete_extension -lcore_functions_extension -licu_extension -ljson_extension -lparquet_extension -ltpcds_extension -ltpch_extension -lduckdb_fastpforlib -lduckdb_fmt -lduckdb_fsst -lduckdb_hyperloglog -lduckdb_mbedtls -lduckdb_miniz -lduckdb_pg_query -lduckdb_re2 -lduckdb_skiplistlib -lduckdb_utf8proc -lduckdb_yyjson -lduckdb_zstd -lc++ -L${SRCDIR}
#include <duckdb.h>
*/
import "C"
