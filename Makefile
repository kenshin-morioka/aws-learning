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

.PHONY: help check-tools fmt validate lint diagram check

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

validate: ## Terraform と SAM を validate する
	@echo "(ステップ4で実装予定: terraform validate / sam validate)"

lint: ## TFLint / Checkov / cfn-lint を実行する
	@echo "(ステップ4で実装予定)"

diagram: ## Terraform と SAM の構成図を生成する
	@echo "(ステップ5で実装予定)"

check: check-tools fmt validate lint diagram ## 上記すべてを一括実行する
