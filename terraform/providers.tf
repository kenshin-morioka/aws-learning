# AWS プロバイダの設定。
#
# このリポジトリの学習フローは `terraform validate` 専用 (validate は AWS に接続しない)。
# 以下の skip_* は認証まわりの「事前チェック」を省略する設定で、
# AWS API への通信そのものを遮断するわけではない点に注意。
# plan/apply を実行すると AWS エンドポイントへの接続を試みる (ダミー認証情報のため
# 認証エラーで失敗し、リソースが作られることはないが「無通信」の保証はない)。
provider "aws" {
  region = var.aws_region

  # validate だけで完結させるための学習用設定
  skip_credentials_validation = true # STS による認証情報の検証をしない
  skip_metadata_api_check     = true # EC2 メタデータ API を参照しない
  skip_requesting_account_id  = true # アカウント ID を取得しない

  # ダミーの認証情報 (実在しない値なので apply しても認証エラーになる)
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"
}
