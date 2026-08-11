//! プレースホルダの Rust Lambda ハンドラ。
//!
//! Python 版 (src/hello/) との違い:
//! - Rust はコンパイル済みバイナリを custom runtime (provided.al2023) で動かす
//! - GC やインタプリタが無いため、メモリ使用量とコールドスタートを最小化できる
//!
//! 実装を始めたら自由に置き換えてよい。

use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde_json::{json, Value};

async fn handler(_event: LambdaEvent<Value>) -> Result<Value, Error> {
    Ok(json!({
        "statusCode": 200,
        "body": "hello from rust",
    }))
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(service_fn(handler)).await
}
