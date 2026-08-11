# variable = 外から注入できる「入力値」。`var.xxx` で参照する。
#
# TODO: 必要な変数をここに定義する。

# providers.tf で参照しているリージョンだけ土台として定義済み
variable "aws_region" {
  description = "リソースを作成する想定の AWS リージョン (東京)"
  type        = string
  default     = "ap-northeast-1"
}
