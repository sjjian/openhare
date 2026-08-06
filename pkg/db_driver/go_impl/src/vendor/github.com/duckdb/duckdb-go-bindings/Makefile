DUCKDB_VERSION=v1.5.5

fetch.static.libs:
	cd lib/${PLATFORM} && \
	curl -OL https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/${FILENAME}.zip && \
	rm -f *.a duckdb.h && \
	unzip ${FILENAME}.zip && \
	rm -f ${FILENAME}.zip && \
	if [ -n "${COPY_HEADER}" ]; then cp duckdb.h ../../include/; fi

test.dynamic.lib:
	mkdir dynamic-dir && \
	cd dynamic-dir && \
	curl -OL https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/${FILENAME}.zip && \
	unzip ${FILENAME}.zip
