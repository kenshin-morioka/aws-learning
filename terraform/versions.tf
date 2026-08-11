# Terraform 本体と、使用するプロバイダのバージョンを固定するファイル。
# バージョンを固定することで「人によって挙動が違う」事故を防ぐ。
terraform {
  required_version = ">= 1.9"

  required_providers {
    # AWS リソース (aws_vpc, aws_lambda_function など) を定義するためのプロバイダ
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # 6.x 系の最新を許可 (7.0 には上げない)
    }
  }
}
