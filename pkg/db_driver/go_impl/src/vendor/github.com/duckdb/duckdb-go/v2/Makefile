DUCKDB_VERSION=v1.5.5

test.examples:
	go run examples/appender/main.go
	go run examples/json/main.go
	go run examples/scalar_udf/main.go
	go run examples/simple/main.go
	go run examples/table_udf/main.go
	go run examples/table_udf_parallel/main.go

test.dynamic.lib:
	mkdir dynamic-dir && \
	cd dynamic-dir && \
	curl -OL https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/${FILENAME}.zip && \
	unzip ${FILENAME}.zip

test.static.lib.darwin.arm64:
	mkdir static-dir && \
	cd static-dir && \
	curl -OL https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/static-libs-osx-arm64.zip && \
	unzip static-libs-osx-arm64.zip

GOBIN ?= $$(go env GOPATH)/bin

install-go-test-coverage:
	go install github.com/vladopajic/go-test-coverage/v2@latest

check-coverage: install-go-test-coverage
	go test ./... -coverprofile=./cover.out -covermode=atomic -coverpkg=./...
	${GOBIN}/go-test-coverage --config=./.github/testcoverage.yml
	go tool cover -html=cover.out -o=cover.html
