"""プレースホルダの Lambda ハンドラ。

template.yaml の HelloFunction から参照されている。
実装を始めたら自由に置き換えてよい。
"""


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "hello",
    }
