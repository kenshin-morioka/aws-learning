# AWS プロバイダの設定。
#
# このリポジトリは「validate するだけで AWS には一切接続しない」学習用なので、
# 認証情報の検証などをすべてスキップし、ダミーの認証情報を設定している。
# 万が一 plan/apply を実行しても実際の AWS アカウントには繋がらない。
provider "aws" {
  region = var.aws_region

  # AWS への接続を避けるための学習用設定
  skip_credentials_validation = true # 認証情報の検証をしない
  skip_metadata_api_check     = true # EC2 メタデータ API を参照しない
  skip_requesting_account_id  = true # アカウント ID を取得しない

  # ダミーの認証情報 (実在しない値)
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"
}
