<p align="center">
  <img src="assets/logo.png" alt="go-db2 Logo" width="480" />
</p>

# go-db2

> Pure Go database driver for **IBM Db2**, fully compatible with Go's standard [`database/sql`](https://pkg.go.dev/database/sql).

[![Go Reference](https://pkg.go.dev/badge/github.com/go-db2/go-db2.svg)](https://pkg.go.dev/github.com/go-db2/go-db2)
[![CI/CD Pipeline](https://github.com/go-db2/go-db2/actions/workflows/ci.yml/badge.svg)](https://github.com/go-db2/go-db2/actions/workflows/ci.yml)
[![Go Version](https://img.shields.io/badge/Go-1.22+-00ADD8?logo=go)](https://go.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🚀 Overview

`go-db2` is a high-performance, open-source database driver written **100% in Pure Go** to connect Go applications directly to **IBM Db2** over TCP/TLS using the native **DRDA** (*Distributed Relational Database Architecture*) and **DDM** (*Distributed Data Management*) wire protocols.

### Why `go-db2`?
- **100% Pure Go (`CGO_ENABLED=0`)**: Zero CGO, zero `unsafe`, and zero external C library dependencies. No need to install IBM's heavy `clidriver` or ODBC components.
- **Trivial Cross-Compilation & Portability**: Build small, static binaries for Linux (x86_64, ARM64), macOS (including Apple Silicon M1/M2/M3/M4), Windows, and lightweight container base images (`scratch`, `distroless`, Alpine Linux).
- **Standard `database/sql` & Ecosystem Ready**: Native support for Go's connection pooling, explicit transactions with ACID isolation, contexts/timeouts/cancellations, and seamless compatibility with ORMs and tools such as `sqlx`, `GORM`, `sqlc`, and `golang-migrate`.
- **Exceptional Performance & Low Memory Footprint**: Up to **31x faster** for single-row queries, **326x faster** on bulk row scans, **1.257x faster** for prepared statement inserts, and up to **770x lower memory allocation** than IBM's CGO driver.

---

## ✨ Feature Matrix

| Feature | Status | Description |
| :--- | :---: | :--- |
| **Pure Go Engine** | ✅ Supported | 100% Go implementation with native DRDA/DDM binary protocol parser |
| **Authentication & Handshake** | ✅ Supported | SECMEC 3 (Plain), SECMEC 9 (Diffie-Hellman + DES), EBCDIC CP500 exchange |
| **TLS/SSL & mTLS Encryption** | ✅ Supported | Native TLS 1.2+ (`crypto/tls`) with custom Root CAs and client certificate/key authentication |
| **`database/sql` Registration** | ✅ Supported | `sql.Register("db2", ...)` with standard URL and Key-Value DSN parsers |
| **Connection Pooling & Liveness** | ✅ Supported | `db.PingContext()`, `driver.Connector`, transparent pool lifecycle management |
| **Transactions & ACID Isolation** | ✅ Supported | `db.BeginTx()`, `tx.Commit()`, `tx.Rollback()` with strict auto-commit management |
| **DDL & DML Execution** | ✅ Supported | `db.ExecContext()` for `CREATE`, `DROP`, `INSERT`, `UPDATE`, `DELETE` |
| **Query & Streaming Rows** | ✅ Supported | `db.QueryContext()`, `db.QueryRowContext()`, `rows.Scan()`, `rows.Columns()` |
| **Type Conversions & NULLs** | ✅ Supported | Integers, Varchars, Floats, Dates, Timestamps, Decimals, Booleans, `sql.Null*` |
| **Prepared Statements & Params** | ✅ Supported | Positional `?` parameter binding (`FDODSC`, `FDODTA`, `SQLDTA`) with single roundtrip reuse |
| **LOBs (BLOB / CLOB / DBCLOB)** | ✅ Supported | Large binary and text streaming via DRDA `EXTDTA` (`0x146C`) packet collection |
| **Stored Procedures & `sql.Out`** | ✅ Supported | `CALL procedure(?, ...)` supporting `IN`, `OUT`, and `INOUT` parameters via `SQLDTARD` |
| **Multi-Result Sets** | ✅ Supported | Full `driver.RowsNextResultSet` implementation for procedures returning multiple cursors |
| **`Result.LastInsertId()`** | ✅ Supported | Automatic identity recovery on `INSERT` via `IDENTITY_VAL_LOCAL()` |
| **Extended Data Types** | ✅ Supported | `DECFLOAT(16/34)` (IEEE 754-2008 DPD), `XML` documents, `TIMESTAMP WITH TIME ZONE` |
| **Graphic & DBCS Types** | ✅ Supported | `GRAPHIC`, `VARGRAPHIC`, `LONG VARGRAPHIC`, `DBCLOB`, `CODEUNITS32` |
| **Batch / Array Parameter DML** | ✅ Supported | High-throughput bulk operations with primitive slices (`[]int`, `[]string`, `[]float64`) |
| **Admin DB Management & APIs** | ✅ Supported | `CreateDb()`, `DropDb()`, and `ExecAdminCmd()` (`SYSPROC.ADMIN_CMD`) |
| **Kerberos SSO & GSSAPI Auth** | ✅ Supported | Network directory authentication (`SECMEC 7/11`) via `ccache`, `keytab`, or domain credentials |
| **Trusted Context & User Switching** | ✅ Supported | Microsecond user/tenant identity transition (`SwitchUser`, `WithUser`) on pooled connections |
| **Client Workstation & Accounting** | ✅ Supported | Workload identification & APM registers (`CLIENT APPLNAME`, `WRKSTNNAME`, `USERID`, `ACCTNG`) |
| **Adaptive Block Fetching** | ✅ Supported | Configurable buffer block size via DSN (`?block_size=131072`) with DRDA `QRYBLKSZ` |
| **Query Cancellation (`SQLINTR`)** | ✅ Supported | Asynchronous cancellation signal and timeout aborts via DRDA `SQLINTR` (`0x2007`) |
| **Security Hardening & Redaction** | ✅ Supported | Sensitive fields redacted in `fmt.Stringer`, regex identifier validation, zero data races |

---

## 📦 Installation

```bash
go get github.com/go-db2/go-db2
```

Requires Go **1.22** or higher.

---

## 🔧 Connection String & DSN Reference

`go-db2` supports both standard **URL format** and **Key-Value (ODBC-style) format**.

### 1. URL Format (Recommended)
```text
db2://[username:password@]host[:port]/database[?param1=value1&param2=value2]
```
*Example:*
```text
db2://db2inst1:SecretPass123@127.0.0.1:50000/TESTDB?ssl=false
```

### 2. Key-Value Format
```text
host=127.0.0.1;port=50000;database=TESTDB;uid=db2inst1;pwd=SecretPass123;ssl=false;
```

### 📋 Supported DSN Parameters

| Parameter | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| `ssl` / `tls` | `bool` | `false` | Enable TLS/SSL encrypted connection (enforces TLS 1.2+). |
| `ssl_ca` | `string` | `""` | Path to custom Root CA certificate file (PEM format). |
| `ssl_cert` | `string` | `""` | Path to client certificate file for mTLS authentication. |
| `ssl_key` | `string` | `""` | Path to client private key file for mTLS authentication. |
| `security_mechanism` / `secmec` | `string` | `plain` | Authentication mode: `plain` (SECMEC 3), `encrypted-password` (SECMEC 9 - DH+DES), or `kerberos` (SECMEC 7/11). |
| `spn` | `string` | `""` | Kerberos Service Principal Name (e.g. `db2/server.corp.local@CORP.LOCAL`). |
| `krb5_keytab` | `string` | `""` | Path to Kerberos `.keytab` file for background authentication. |
| `krb5_ccache` | `string` | `""` | Path to Kerberos credential cache (`/tmp/krb5cc_...`). |
| `client_applname` | `string` | `""` | Initial `CURRENT CLIENT_APPLNAME` special register for APM/tracing. |
| `client_wrkstnname` | `string` | `""` | Initial `CURRENT CLIENT_WRKSTNNAME` special register (host/pod name). |
| `client_userid` | `string` | `""` | Initial `CURRENT CLIENT_USERID` special register. |
| `client_acctng` | `string` | `""` | Initial `CURRENT CLIENT_ACCTNG` accounting string. |
| `block_size` | `int` | `32768` | DRDA `QRYBLKSZ` buffer block size in bytes (e.g. `65536`, `131072`). |
| `timeout` | `duration`| `15s` | Query execution and socket read/write timeout (e.g. `30s`, `1m`). |
| `conn_timeout` | `duration`| `10s` | Initial TCP connect and handshake timeout. |

---

## 💡 Code Examples

### 1. Basic Connection & Query
```go
package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"time"

	_ "github.com/go-db2/go-db2"
)

func main() {
	db, err := sql.Open("db2", "db2://db2inst1:MinhaSenhaForte123@127.0.0.1:50000/TESTDB?ssl=false")
	if err != nil {
		log.Fatalf("Failed to open db: %v", err)
	}
	defer db.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		log.Fatalf("Ping failed: %v", err)
	}

	var greeting string
	err = db.QueryRowContext(ctx, "SELECT 'Hello from IBM Db2!' FROM SYSIBM.SYSDUMMY1").Scan(&greeting)
	if err != nil {
		log.Fatalf("Query failed: %v", err)
	}
	fmt.Println(greeting)
}
```

### 2. Explicit Transactions (ACID Isolation)
```go
tx, err := db.BeginTx(ctx, nil)
if err != nil {
    log.Fatal(err)
}
defer tx.Rollback() // Safe: no-op if committed

_, err = tx.ExecContext(ctx, "INSERT INTO accounts (id, balance) VALUES (?, ?)", 101, 5000.00)
if err != nil {
    return err
}

_, err = tx.ExecContext(ctx, "UPDATE accounts SET balance = balance - ? WHERE id = ?", 200.00, 101)
if err != nil {
    return err
}

if err := tx.Commit(); err != nil {
    log.Fatal(err)
}
```

### 3. Stored Procedures with `sql.Out` & Multi-Result Sets
```go
// Stored procedure with IN and OUT parameters
var outTotal int
var outStatus string

_, err := db.ExecContext(ctx, "CALL PROCESS_ORDER(?, ?, ?)", 
    1001, 
    sql.Out{Dest: &outTotal}, 
    sql.Out{Dest: &outStatus},
)

// Stored procedure returning multiple result sets (cursors)
rows, err := db.QueryContext(ctx, "CALL GET_CUSTOMER_AND_ORDERS(?)", 42)
if err != nil {
    log.Fatal(err)
}
defer rows.Close()

// 1. Process first result set (Customer details)
for rows.Next() {
    var name, email string
    _ = rows.Scan(&name, &email)
}

// 2. Advance to second result set (Customer orders)
if rows.NextResultSet() {
    for rows.Next() {
        var orderID int
        var total float64
        _ = rows.Scan(&orderID, &total)
    }
}
```

### 4. Client Telemetry & APM Tracking (`WithClientInfo`)
```go
import "github.com/go-db2/go-db2"

// Inject telemetry context into any query or transaction
clientCtx := db2.WithClientInfo(ctx, db2.ClientInfo{
    ApplicationName: "orders-microservice",
    WorkstationName: "k8s-worker-node-04",
    UserID:          "app_user_42",
    Accounting:      "billing_dept",
})

// Db2 special registers (CURRENT CLIENT_APPLNAME, etc.) are automatically synchronized
rows, err := db.QueryContext(clientCtx, "SELECT * FROM orders WHERE status = ?", "PENDING")
```

### 5. High-Throughput Batch / Bulk DML
```go
// Bulk insert 1,000 rows in a single DRDA network operation
productIDs := []int{101, 102, 103, 104}
skus := []string{"SKU-A", "SKU-B", "SKU-C", "SKU-D"}
prices := []float64{19.99, 29.50, 49.00, 99.90}

result, err := db.ExecContext(ctx, 
    "INSERT INTO products (id, sku, price) VALUES (?, ?, ?)", 
    productIDs, skus, prices,
)
```

---

## ⚡ Performance & Conformance Benchmarks

`go-db2` includes a fully automated containerized benchmark and semantic conformance suite comparing it directly against the official IBM CGO driver (`go_ibm_db`).

### 1. Semantic Conformance (Result Parity)
Verified against live IBM Db2: **100% PASS** (8/8 test suites). All scalar types, nullables, high-precision decimals (`DECFLOAT(34)`), dates/timestamps, DBCS strings (`VARGRAPHIC`), and binary `BLOB` payloads (verified via SHA-256 hash match) produce **byte-for-byte identical results**.

### 2. Performance & Memory Comparison

| Scenario | `go-db2` (Pure Go) | `go_ibm_db` (CGO / CLI) | Speedup / Ratio | Memory / Allocations |
| :--- | :---: | :---: | :---: | :---: |
| **Simple Single-Row SELECT** | **8.37 µs** | 259.84 µs | **31.05x faster** 🚀 | **1.3 KB** vs 1.9 KB |
| **Fetch 1,000 Rows Scan** | **16.37 µs** | 5.35 ms | **326.80x faster** 🚀 | **1.3 KB** vs 97.9 KB (73x less) |
| **Prepared Statement INSERT** | **14.90 µs** | 18.74 ms | **1.257,79x faster** 🚀 | **2.4 KB** vs 11.5 KB |
| **Read 500KB BLOB Payload** | **29.12 µs** | 1.94 ms | **66.74x faster** 🚀 | **1.3 KB** vs 1.05 MB (770x less) |

> 📖 **Full Report**: See [benchmarks/RESULTS.md](benchmarks/RESULTS.md) for full benchmark breakdown.
>
> 🐳 **Reproduce in Container (Zero host setup required)**:
> ```bash
> ./benchmarks/run_benchmark.sh
> ```

---

## 🧪 Testing

### 1. Run Unit Tests & Security Race Checks
```bash
go test -v -race -timeout 5m -count=1 ./...
```

### 2. Run Live Tests against Local Db2 Container
Start the official IBM Db2 container:
```bash
podman run -d \
  --name db2-test \
  --privileged \
  -p 50000:50000 \
  -e LICENSE=accept \
  -e DB2INST1_PASSWORD=MinhaSenhaForte123 \
  -e DBNAME=testdb \
  -e PERSISTENT_HOME=false \
  icr.io/db2_community/db2
```

Run all 15 integration examples:
```bash
go run examples/basic_connect/main.go
go run examples/crud_demo/main.go
go run examples/params_demo/main.go
go run examples/lob_demo/main.go
go run examples/sp_demo/main.go
go run examples/sp_multi_results_demo/main.go
go run examples/sqlx_demo/main.go
go run examples/identity_demo/main.go
go run examples/extended_types_demo/main.go
go run examples/batch_dml_demo/main.go
go run examples/admin_db_demo/main.go
go run examples/graphic_dbcs_demo/main.go
go run examples/kerberos_auth_demo/main.go
go run examples/trusted_context_demo/main.go
go run examples/client_accounting_demo/main.go
```

---

## 📋 Planning & Project Architecture

- 🇬🇧 **[PROJECT_PLAN.md](PROJECT_PLAN.md)** (English)
- 🇧🇷 **[PROJECT_PLAN.pt-BR.md](PROJECT_PLAN.pt-BR.md)** (Português do Brasil)

---

## 📜 License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
