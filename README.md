# aws-learning

Terraform / AWS SAM の記述と AWS アーキテクチャの関係を学ぶためのリポジトリ。

> **このリポジトリは AWS へデプロイしない学習環境です。**
> AWS アカウントも credentials も不要。すべての検証・図生成はローカルで完結し、AWS 利用料金は発生しません。
> 安全のため `apply` / `deploy` / `destroy` にあたるタスクは存在しません。

`terraform/` と `sam/` は骨格(プレースホルダ)の状態です。アーキテクチャを設計し、リソースを実装するのは利用者自身。このリポジトリが提供するのは「書いた IaC を検証して構成図にする仕組み」です。

## 学習サイクル

```text
IaC を書く (terraform/*.tf, sam/template.yaml)
   ↓
mise run check
   ↓
validate / lint で文法・セキュリティを検証
   ↓
構成図が自動生成される (diagrams/)
   ↓
図を見て構造を確認 → IaC を修正
```

## セットアップ (macOS)

```bash
# 1. mise (ツール管理・タスクランナー) — 未導入なら
brew install mise   # シェル設定は https://mise.jdx.dev/getting-started.html

# 2. mise 管理のツール (terraform / tflint / checkov / cfn-lint / cfn-diagram)
mise install

# 3. mise 管理外のツール
brew install aws-sam-cli graphviz inframap

# 4. 揃ったか確認
mise run check-tools
```

Linux の場合は 3 を各ディストリビューションのパッケージマネージャで導入してください
(InfraMap はバイナリ配布が無いため `go install github.com/cycloidio/inframap@v0.8.1`)。

## 基本操作

```bash
mise run check      # 全チェック一括 (fmt-check → validate → lint → diagram)
mise tasks          # タスク一覧
```

| タスク | 内容 |
|---|---|
| `mise run fmt` | Terraform コードの整形 |
| `mise run validate` | terraform validate + sam validate --lint |
| `mise run lint` | TFLint / cfn-lint / Checkov |
| `mise run diagram` | 構成図の生成 |
| `mise run check-tools` | 必要ツールの確認 |

## 使用ツールと役割

| ツール | 役割 |
|---|---|
| Terraform | AWS リソースをコードで定義 (IaC) |
| AWS SAM CLI | サーバーレス構成 (template.yaml) の検証 |
| TFLint | Terraform の lint |
| cfn-lint | CloudFormation / SAM の lint |
| Checkov | IaC のセキュリティ静的解析 |
| InfraMap + Graphviz | Terraform から構成図 (SVG) を生成 |
| cfn-diagram | SAM から構成図 (Mermaid) を生成 |
| mise | 上記ツールのバージョン管理 (mise.toml) とタスク実行 |

### ツール選定の補足

- **Terraform / TFLint を mise で管理する理由**: Terraform は 2023 年の BUSL ライセンス変更により Homebrew 公式 (homebrew-core) から削除されており、brew では入らないため
- **Makefile ではなく mise tasks の理由**: ツール導入に mise が必須である以上、タスクランナーも mise に統一する方が構成が単純になるため (`mise run` はツールの PATH 解決も自動で効く)
- **InfraMap**: メンテナンス状況を確認の上採用 (2026-04 に v0.8.1 リリース、現役)

## Terraform 側の構成

| ファイル | 担当 |
|---|---|
| `versions.tf` | Terraform 本体と AWS プロバイダのバージョン固定 |
| `providers.tf` | AWS プロバイダ設定。validate 専用のダミー認証情報 (AWS へ接続しない) |
| `variables.tf` | 入力値 (variable) の定義 |
| `main.tf` | リソース定義の起点 (実装はここから。ファイル分割・modules 化は自由) |
| `outputs.tf` | 出力値 (output) の定義 |

- Terraform に「エントリーポイント」は無く、ディレクトリ内の全 `*.tf` がマージされて評価される。ファイル名は慣習にすぎない
- `.terraform.lock.hcl` は**コミットする方針**: プロバイダのバージョンを固定し、誰が実行しても同じ挙動になるようにするため (一般的な推奨に従う)
- `terraform plan` は AWS API へ接続を試みるため学習フローには含めない (validate まで)

## SAM 側の構成

`sam/template.yaml` の主要セクション:

| セクション | 意味 |
|---|---|
| `Transform` | このテンプレートを SAM 記法として解釈させる宣言 |
| `Resources` | リソース定義の本体 (実装はここから) |
| `Globals` / `Outputs` など | 実装時に必要に応じて追加 |

プレースホルダとして 2 つのランタイムパターンを置いてある (実装時に置き換え可):

- **Python (マネージドランタイム)** — 標準的な形。ビルド不要で IaC 学習に集中できる
- **Rust (カスタムランタイム / provided.al2023)** — 実行メモリ最小・コールドスタート高速が必要なケース向け。ビルドを試す場合のみ `rustup` と `cargo-lambda` が必要

検証は `sam validate --lint` (cfn-lint によるローカル検証、AWS 接続なし) を使う。`--lint` なしの `sam validate` は AWS 認証情報とリージョン設定を要求するため学習フローでは使わない。

## 構成図

`mise run diagram` で生成される (以下は骨格状態のため空。リソースを実装すると育つ):

![Terraform Architecture](diagrams/terraform/architecture.svg)

SAM の構成図 (Mermaid): [diagrams/sam/architecture.md](diagrams/sam/architecture.md)

## CI (GitHub Actions)

push / PR 時に `mise run check` と同じ検証を実行する (`.github/workflows/validate.yml`)。
AWS credentials は一切使用しない (GitHub Secrets にも設定しない)。

## セキュリティ警告との付き合い方

Checkov の警告は「なぜその設定が重要か」を学ぶ教材として扱う。プレースホルダに対する警告は
理由をコメントで説明した上で `Metadata.checkov.skip` により明示的にスキップしている
(`sam/template.yaml` 参照)。実装時は各項目を自分で設計判断すること。

## 初心者向け用語ミニ辞典

| 用語 | 意味 |
|---|---|
| resource | Terraform で「作る対象」を宣言するブロック。1 resource ≒ 1 AWS リソース |
| data | 既存のものを「参照するだけ」のブロック (作らない) |
| variable | 外から注入できる入力値。`var.xxx` で参照 |
| output | apply 後に表示される出力値 |
| reference (参照) | `aws_vpc.main.id` のように他リソースの属性を使うこと。これが依存関係になる |
| depends_on | 参照関係が無いのに順序を強制したいときの明示的な依存指定 |
| ARN | AWS リソースを一意に識別する ID (Amazon Resource Name) |
| IAM policy | 「誰が・何に・どんな操作を」許可するかの定義 |
| VPC | AWS 上に作る自分専用の仮想ネットワーク |
| Subnet | VPC を分割した区画。インターネットへの経路があると Public、無いと Private |
| Security Group | インスタンスや Lambda に付ける仮想ファイアウォール |

## ディレクトリ構成

```text
.
├── mise.toml            # ツールのバージョン固定 + タスク定義
├── terraform/           # Terraform (実装場所)
├── sam/                 # SAM (実装場所)
│   └── src/             #   Lambda のコード (Python / Rust)
├── diagrams/            # 生成される構成図
├── scripts/             # check-tools / 図生成スクリプト
├── docs/specification.md # このリポジトリの仕様書
└── .github/workflows/   # CI (静的チェックのみ)
```
