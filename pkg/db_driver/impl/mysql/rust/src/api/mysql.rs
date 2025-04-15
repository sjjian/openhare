use mysql_async::{prelude::*, Conn, Opts, OptsBuilder, Value};
use chrono::NaiveDate;

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
            },
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
            },
            Value::NULL => QueryValue::NULL,
        }
    }
}

pub struct QueryResult {
    pub columns: Vec<QueryColumn>,
    pub rows: Vec<QueryRow>,
    pub affected_rows: u64,
}

pub struct QueryColumn {
    pub name: String,
    pub column_type: u8,
}

pub struct QueryRow {
    pub values: Vec<QueryValue>,
}

impl QueryColumn {
    #[flutter_rust_bridge::frb(ignore)]
    pub fn from_column(col: &mysql_async::Column) -> Self {
        QueryColumn {name:col.name_str().to_string(), column_type: col.column_type() as u8}
    }
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

    pub async fn query(&mut self, query: &str) -> Result<QueryResult, String> {
        let mut result_set = self
            .conn
            .query_iter(query)
            .await
            .map_err(|e| e.to_string())?;

        // 获取列信息
        let columns = result_set
            .columns()
            .ok_or("Failed to fetch column metadata".to_string())?
            .iter()
            .map(QueryColumn::from_column)
            .collect();

        // 解析行数据
        let mut rows = Vec::new();
        while let Some(row_result) = result_set.next().await.transpose() {
            let row = row_result.map_err(|e| e.to_string())?; 
            let values = row
                .unwrap() 
                .into_iter()
                .map(QueryValue::from_value)
                .collect();
            rows.push(QueryRow { values });
        }
        
        let affected_rows = result_set.affected_rows();

        Ok(QueryResult { columns, rows, affected_rows })
    }

    pub async fn close(self) -> Result<(), String> {
        self.conn.disconnect().await.map_err(|e| e.to_string())
    }
}
