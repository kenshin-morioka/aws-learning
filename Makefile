# AWS IaC 学習用リポジトリの操作をまとめる Makefile
#
# 安全対策: このリポジトリは AWS へデプロイしない。
# そのため apply / deploy / destroy ターゲットは意図的に存在しない。

SHELL := /bin/bash

# terraform / tflint などは mise で管理している (mise.toml 参照)。
# make の非対話シェルには mise の PATH 設定が効かないため、
# mise があれば `mise exec -- <コマンド>` 経由で実行する。
# (macOS 標準の GNU Make 3.81 は Makefile 内での PATH 変更を直接実行時に反映しないため)
MISE := $(shell command -v mise 2>/dev/null)
RUN := $(if $(MISE),$(MISE) exec --,)

TERRAFORM_DIR := terraform
SAM_DIR := sam

.PHONY: help check-tools fmt fmt-check validate validate-terraform validate-sam \
	lint lint-tflint lint-cfn lint-checkov diagram diagram-terraform diagram-sam check

# デフォルトターゲット(make だけ打った場合)
.DEFAULT_GOAL := help

help: ## このヘルプを表示する
	@echo "使い方: make <ターゲット>"
	@echo ""
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  %-14s %s\n", $$1, $$2}'

check-tools: ## 必要な CLI がインストールされているか確認する
	@bash scripts/check-tools.sh

fmt: ## Terraform コードをフォーマットする
	$(RUN) terraform -chdir=$(TERRAFORM_DIR) fmt -recursive

fmt-check: ## フォーマット崩れがないか確認する (書き換えはしない)
	$(RUN) terraform -chdir=$(TERRAFORM_DIR) fmt -check -recursive -diff

validate: validate-terraform validate-sam ## Terraform と SAM を validate する

validate-terraform: ## terraform validate を実行する
	@# validate にはプロバイダの取得 (init) が必要。初回のみ実行される
	@test -d $(TERRAFORM_DIR)/.terraform || $(RUN) terraform -chdir=$(TERRAFORM_DIR) init -backend=false -input=false
	$(RUN) terraform -chdir=$(TERRAFORM_DIR) validate

validate-sam: ## sam validate --lint を実行する (オフラインで完結)
	$(RUN) sam validate --lint --template-file $(SAM_DIR)/template.yaml

lint: lint-tflint lint-cfn lint-checkov ## TFLint / cfn-lint / Checkov を実行する

lint-tflint: ## Terraform の lint
	$(RUN) tflint --chdir=$(TERRAFORM_DIR)

lint-cfn: ## CloudFormation / SAM の lint
	$(RUN) cfn-lint $(SAM_DIR)/template.yaml

lint-checkov: ## IaC のセキュリティ静的解析 (Terraform + SAM)
	$(RUN) checkov --directory $(TERRAFORM_DIR) --directory $(SAM_DIR) --quiet --compact

diagram: diagram-terraform diagram-sam ## Terraform と SAM の構成図を生成する

diagram-terraform: ## Terraform から構成図 (SVG) を生成する
	@bash scripts/generate-terraform-diagram.sh

diagram-sam: ## SAM から構成図 (Mermaid) を生成する
	@bash scripts/generate-sam-diagram.sh

# check では fmt (書き換え) ではなく fmt-check (確認のみ) を使う
check: check-tools fmt-check validate lint diagram ## 上記すべてを一括実行する
