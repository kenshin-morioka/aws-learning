# AWS IaC 学習用リポジトリを作成してください

Terraform と AWS SAM を使って AWS インフラ構築を学習するための、ローカル完結型の学習用 GitHub リポジトリを作成してください。

## 目的

このリポジトリでは、実際の AWS 環境へデプロイせずに、

1. Terraform を正しく記述する
2. AWS SAM / CloudFormation を正しく記述する
3. 静的解析・validate を実行する
4. IaC の内容から AWS アーキテクチャ図を生成する
5. GitHub にコードと生成された構成図を保存する

という流れを学習できるようにしたいです。

実際にアプリケーションが動作する必要はありません。

最重要なのは、

「IaC を書く → validate する → 構成図を見る」

という学習サイクルです。

---

# 重要な制約

- AWS へのデプロイは絶対に行わない
- `terraform apply` を実行しない
- `sam deploy` を実行しない
- AWS 上にリソースを作成しない
- AWS 利用料金が発生しない構成にする
- AWS アカウントや AWS credentials がなくても、可能な限り利用できるようにする
- LocalStack は今回は不要
- 実行環境のエミュレーションは不要
- Lambda が実際に動作する必要もない
- 学習目的なので、コードには適度にコメントを入れる
- README を読めば環境構築から使い方まで理解できる状態にする
- macOS / Linux を主な対象にする

AWS への接続が必要になる処理は作らないでください。

---

# 使用技術

基本的に以下を使用してください。

- Terraform
- AWS Provider
- AWS SAM CLI
- CloudFormation / SAM
- InfraMap
- Graphviz
- cfn-diagram
- TFLint
- Checkov
- cfn-lint
- Makefile
- GitHub Actions

ただし、現在利用困難・非推奨・メンテナンス停止などの理由があるツールについては、目的を満たすより適切なOSSツールへ置き換えて構いません。

その場合は README に理由を書いてください。

---

# 作成したいディレクトリ構成

以下をベースにしてください。

```text
aws-iac-study/
├── README.md
├── Makefile
├── .gitignore
├── .editorconfig
│
├── terraform/
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── main.tf
│   ├── networking.tf
│   ├── security.tf
│   ├── application.tf
│   └── storage.tf
│
├── sam/
│   ├── template.yaml
│   └── src/
│       └── hello/
│           └── app.py
│
├── diagrams/
│   ├── terraform/
│   └── sam/
│
├── scripts/
│   ├── check-tools.sh
│   ├── generate-terraform-diagram.sh
│   └── generate-sam-diagram.sh
│
└── .github/
    └── workflows/
        └── validate.yml
```

必要なら適切に変更して構いません。

---

# Terraform の学習用構成

Terraform 側には、AWS の典型的な Web アプリケーション構成を定義してください。

実際には作成しませんが、コード上は例えば以下の関係が理解できるようにしてください。

```text
Internet
   |
   v
API Gateway
   |
   v
Lambda
   |
   +--------> DynamoDB
   |
   +--------> S3
```

さらに Terraform の学習として、

- VPC
- Public Subnet
- Private Subnet
- Route Table
- Security Group
- IAM Role
- Lambda
- API Gateway
- DynamoDB
- S3

など、AWS の代表的なリソースをある程度含めてください。

ただし「構成を複雑にすること」が目的ではありません。

初心者がファイルを読んで、

「この Terraform resource がこの AWS リソースになる」

「この値を参照しているから、このリソース同士が依存している」

と理解できる程度の規模にしてください。

---

# Terraform のルール

Terraform では、

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
```

が実行できるようにしてください。

可能であれば、

```bash
tflint
checkov
```

も実行します。

AWS backend や remote state は使用しないでください。

学習用なので local state を GitHub にコミットする必要もありません。

`.gitignore` で以下などを適切に除外してください。

```text
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
```

ただし `.terraform.lock.hcl` は一般的にコミットすべきと判断した場合は、学習目的として適切な方針を採用し、その理由を README に説明してください。

---

# SAM の学習用構成

SAM 側では、

```text
API Gateway
     |
     v
Lambda
     |
     v
DynamoDB
```

程度のシンプルな Serverless アプリケーションを作成してください。

`template.yaml` から、

- Lambda
- API Gateway
- DynamoDB
- IAM 権限
- Environment Variables
- Outputs

などを学べるようにしてください。

Lambda のコードは最低限で構いません。

Python を使用してください。

例えば、

```python
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "hello"
    }
```

程度で十分です。

Lambda を実際に起動することは今回の主目的ではありません。

---

# SAM validation

以下が利用できるようにしてください。

```bash
sam validate
sam validate --lint
```

または現在の SAM CLI で推奨される同等のコマンドを利用してください。

---

# Terraform アーキテクチャ図

Terraform のコードから AWS リソースの関係が分かる図を自動生成してください。

第一候補として InfraMap を検討してください。

例えば、

```bash
inframap generate terraform/
```

などから Graphviz を使用し、

```text
diagrams/terraform/architecture.svg
```

を生成できるようにしてください。

ただし InfraMap が現在利用困難・メンテナンス停止・Terraform最新版との互換性に問題がある場合は、より適切なOSSツールへ変更してください。

重要なのはツールそのものではなく、

```text
Terraform
   ↓
解析
   ↓
AWS構成図
```

という体験を作ることです。

図には可能な限り、

- VPC
- Subnet
- API Gateway
- Lambda
- DynamoDB
- S3
- IAM
- Security Group

などの関係が分かるようにしてください。

---

# SAM アーキテクチャ図

`sam/template.yaml` から構成図を生成してください。

第一候補として `cfn-diagram` を検討してください。

可能であれば、

```text
diagrams/sam/architecture.svg
```

または

```text
diagrams/sam/architecture.drawio
```

を生成してください。

Mermaid が適している場合は、

```text
diagrams/sam/architecture.md
```

でも構いません。

GitHub の README 上で構成図が確認できる形式を最低1つ用意してください。

---

# Makefile

リポジトリの操作は、できるだけ Makefile から行えるようにしてください。

最低限以下を用意してください。

```bash
make help
make check-tools
make fmt
make validate
make lint
make diagram
make check
```

期待する意味は以下です。

### make check-tools

必要な CLI がインストールされているか確認する。

### make fmt

Terraform などをフォーマットする。

### make validate

Terraform と SAM を validate する。

### make lint

TFLint / Checkov / cfn-lint などを実行する。

### make diagram

Terraform と SAM の構成図を生成する。

### make check

一括実行する。

イメージ：

```text
Terraform fmt        ✅
Terraform validate   ✅
TFLint               ✅
Checkov              ✅
SAM validate         ✅
cfn-lint             ✅
Terraform diagram    ✅
SAM diagram          ✅
```

---

# 安全対策

このリポジトリから誤って AWS にデプロイしてしまわないようにしてください。

Makefile に以下は作らないでください。

```text
apply
deploy
destroy
```

README にも明確に、

```text
このリポジトリはAWSへデプロイしない学習環境です。
```

と記載してください。

Terraform については、

```bash
terraform plan
```

を実行する場合でも AWS API へアクセスする可能性があるなら、デフォルトの学習フローには含めないでください。

---

# GitHub Actions

GitHub Actions でも静的チェックを行えるようにしてください。

PR または push 時に、

```text
Terraform fmt
Terraform validate
TFLint
SAM validate
cfn-lint
```

などを実行してください。

AWS credentials は GitHub Secrets に設定しないでください。

GitHub Actions から AWS へ接続しないでください。

AWS Access Key / Secret Access Key は使用禁止です。

可能なら構成図生成も GitHub Actions 内で検証してください。

ただし、自動 commit までは不要です。

---

# README

README は特に丁寧に作ってください。

以下の内容を含めてください。

## このリポジトリについて

「AWSを実際に作るのではなく、Terraform/SAMの記述とAWSアーキテクチャの関係を学ぶリポジトリ」であることを説明する。

## 学習サイクル

```text
IaCを書く
   ↓
make check
   ↓
validate / lint
   ↓
構成図生成
   ↓
diagramを見る
   ↓
IaCを修正
```

## 必要なツール

それぞれの役割も説明する。

例：

```text
Terraform
→ AWS infrastructure as code

SAM CLI
→ Serverless Application Model の検証

TFLint
→ Terraform lint

Checkov
→ IaC security/static analysis

cfn-lint
→ CloudFormation / SAM lint

InfraMap
→ Terraformから構成図生成
```

## セットアップ方法

macOS の場合は Homebrew を中心に説明してください。

可能なら、

```bash
make check-tools
```

で不足ツールが分かるようにしてください。

## 基本操作

```bash
make check
```

だけで一連の処理が実行できることを説明してください。

## Terraform の説明

各 `.tf` ファイルが何を担当しているか説明する。

## SAM の説明

`template.yaml` の主要セクションを説明する。

## diagrams

生成された構成図を README に表示してください。

例えば、

```markdown
![Terraform Architecture](diagrams/terraform/architecture.svg)
```

のようにしてください。

---

# コメント・教材としての品質

これは実務用プロジェクトというより「教材」です。

そのため、Terraform や SAM のコードでは、

「何をしているか分かりにくい箇所」

について短いコメントを入れてください。

ただしコメントだらけにはしないでください。

例えば、

```hcl
# Lambda が DynamoDB にアクセスするための IAM Role
resource "aws_iam_role" "lambda" {
}
```

程度です。

README 側では、

```text
resource
data
variable
output
depends_on
reference
IAM policy
ARN
VPC
Subnet
Security Group
```

など、初心者がつまずきやすい用語を簡単に説明してください。

---

# セキュリティ学習

Checkov などの静的解析を入れる場合、最初から完全に警告ゼロを目指すのではなく、

「なぜこの設定がセキュリティ上重要なのか」

が分かる教材にしてください。

ただし CI が常に失敗する状態にはしないでください。

意図的に問題のあるコードを入れる場合は、

```text
examples/insecure/
```

など通常コードとは別の場所にしてください。

---

# 最終的な完成条件

以下を満たした状態を完成としてください。

1. AWS アカウントなしでもコードを読んで学習できる
2. AWS にデプロイしない
3. AWS料金が発生しない
4. Terraform の validate ができる
5. SAM の validate ができる
6. Terraform の lint ができる
7. SAM / CloudFormation の lint ができる
8. Terraform から構成図を生成できる
9. SAM から構成図を生成できる
10. `make check` で主要処理をまとめて実行できる
11. README に生成した AWS 構成図が表示される
12. GitHub Actions でも AWS credentials なしで静的チェックできる
13. `.gitignore` が適切に設定されている
14. GitHub にそのまま push できる
15. 初心者が README を読みながらコードを追える

---

# 作業の進め方

まず現在のディレクトリを確認してください。

その後、

1. 必要なファイルを作成
2. Terraform を実装
3. SAM を実装
4. validate / lint 環境を作成
5. diagram生成を実装
6. Makefile を作成
7. GitHub Actionsを作成
8. READMEを書く
9. 実際にローカルで可能なコマンドを実行して検証
10. エラーがあれば修正

まで進めてください。

不足しているCLIなどのため実行できないものについては、無理にインストールせず、

- 何が不足しているか
- インストール方法
- インストール後に実行すべきコマンド

を最後に報告してください。

AWS credentials の設定を要求しないでください。

AWSへのログインやデプロイもしないでください。

---

# 最後に報告してほしい内容

作業終了後、以下を簡潔に報告してください。

```text
作成したもの
変更したファイル
実行したチェック
成功したチェック
実行できなかったチェック
必要な追加インストール
基本的な使い方
```

また、最初に私が実行すべきコマンドがある場合は最後にまとめてください。

最終的に、

```bash
make check
```

を実行すると、

```text
IaCの検証
↓
静的解析
↓
AWSアーキテクチャ図生成
```

まで完了する学習用リポジトリにしてください。
