# AWS IaC 学習用リポジトリの操作をまとめる Makefile
#
# 安全対策: このリポジトリは AWS へデプロイしない。
# そのため apply / deploy / destroy ターゲットは意図的に存在しない。

# シェルコマンド失敗時に即エラーにする
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

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
	@echo "(ステップ2で実装予定: terraform fmt)"

validate: ## Terraform と SAM を validate する
	@echo "(ステップ4で実装予定: terraform validate / sam validate)"

lint: ## TFLint / Checkov / cfn-lint を実行する
	@echo "(ステップ4で実装予定)"

diagram: ## Terraform と SAM の構成図を生成する
	@echo "(ステップ5で実装予定)"

check: check-tools fmt validate lint diagram ## 上記すべてを一括実行する
