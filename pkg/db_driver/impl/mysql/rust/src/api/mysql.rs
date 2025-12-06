use crate::frb_generated::StreamSink;
use chrono::NaiveDate;
use mysql_async::{prelude::*, Conn, Opts, Value};

pub enum DataType {
    Number,
    Char,
    Time,
    Blob,
    Json,
    DataSet,
}

pub enum QueryValue {
    NULL,
    Bytes(Vec<u8>),
    Int(i64),
    UInt(u64),
    Float(f32),
    Double(f64),
    DateTime(i64),
}

impl QueryValue {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn from_value(value: Value) -> Self {
        match value {
            Value::Int(i) => QueryValue::Int(i),
            Value::UInt(u) => QueryValue::UInt(u),
            Value::Float(f) => QueryValue::Float(f),
            Value::Double(d) => QueryValue::Double(d),
            Value::Bytes(b) => QueryValue::Bytes(b),

            Value::Date(y, m, d, h, min, s, micros) => {
                let dt = NaiveDate::from_ymd_opt(y as i32, m as u32, d as u32)
                    .unwrap()
                    .and_hms_micro_opt(h as u32, min as u32, s as u32, micros as u32)
                    .unwrap();
                let timestamp = dt.and_utc().timestamp_millis();
                QueryValue::DateTime(timestamp)
            }
            Value::Time(is_neg, d, h, min, s, micros) => {
                let total_seconds = (d as i64) * 86400 * 1000
                    + (h as i64) * 3600 * 1000
                    + (min as i64) * 60 * 1000
                    + (s as i64) * 1000
                    + micros as i64;

                let timestamp = if is_neg {
                    -total_seconds
                } else {
                    total_seconds
                };
                QueryValue::DateTime(timestamp)
            }
            Value::NULL => QueryValue::NULL,
        }
    }
}

pub enum QueryStreamItem {
    Header(QueryHeader),
    Row(QueryRow),
    Error(String),
}

pub struct QueryHeader {
    pub columns: Vec<QueryColumn>,
    pub affected_rows: u64,
}

pub struct QueryColumn {
    pub name: String,
    pub column_type: u8,
}

impl QueryColumn {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn from_column(col: &mysql_async::Column) -> Self {
        QueryColumn {
            name: col.name_str().to_string(),
            column_type: col.column_type() as u8,
        }
    }
}

pub struct QueryRow {
    pub values: Vec<QueryValue>,
}

pub struct ConnWrapper {
    conn: Conn,
}

impl ConnWrapper {
    pub async fn open(dsn: &str) -> Result<Self, String> {
        let opts = Opts::from_url(dsn).map_err(|e| e.to_string())?;
        let conn = Conn::new(opts).await.map_err(|e| e.to_string())?;
        Ok(ConnWrapper { conn })
    }

    pub async fn query(
        &mut self,
        query: &str,
        sink: StreamSink<QueryStreamItem>,
    ) -> Result<(), String> {
        let mut result_set = match self.conn.query_iter(query).await {
            Ok(rs) => rs,
            Err(e) => {
                let _ = sink.add(QueryStreamItem::Error(format!("{}", e)));
                return Ok(());
            }
        };

        // 获取列信息
        let columns = match result_set.columns() {
            Some(cols) => cols.iter().map(QueryColumn::from_column).collect(),
            None => {
                let _ = sink.add(QueryStreamItem::Error("Failed to fetch column".to_string()));
                return Ok(());
            }
        };

        let affected_rows = result_set.affected_rows();

        let header: QueryHeader = QueryHeader {
            columns,
            affected_rows,
        };
        if let Err(e) = sink.add(QueryStreamItem::Header(header)) {
            let _ = sink.add(QueryStreamItem::Error(format!(
                "Failed to send header: {}",
                e
            )));
            return Ok(());
        }

        // 然后处理result_set并发送行数据到stream
        while let Some(row_result) = result_set.next().await.transpose() {
            match row_result {
                Ok(row) => {
                    let values = row
                        .unwrap()
                        .into_iter()
                        .map(QueryValue::from_value)
                        .collect();
                    let query_row = QueryRow { values };
                    if let Err(e) = sink.add(QueryStreamItem::Row(query_row)) {
                        let _ =
                            sink.add(QueryStreamItem::Error(format!("Failed to send row: {}", e)));
                        return Ok(());
                    }
                }
                Err(e) => {
                    let _ = sink.add(QueryStreamItem::Error(format!("{}", e)));
                    return Ok(());
                }
            }
        }

        Ok(())
    }

    pub async fn close(self) -> Result<(), String> {
        self.conn.disconnect().await.map_err(|e| e.to_string())
    }
}
