#!/usr/bin/env bash
# 学習に必要な CLI ツールが揃っているかを確認するスクリプト。
# 不足していても即エラーにはせず、最後にまとめて結果を表示する。
set -u

# 必須ツール: 「コマンド名|用途|インストール方法(macOS)」
# terraform / tflint は Homebrew 公式 (homebrew-core) にないため mise で管理する。
# リポジトリ直下の mise.toml にバージョンを固定してあるので `mise install` で一括導入できる。
REQUIRED_TOOLS=(
  "terraform|Terraform 本体 (IaC 記述と validate)|mise install"
  "sam|AWS SAM CLI (template.yaml の validate)|brew install aws-sam-cli"
  "tflint|Terraform の lint|mise install"
  "cfn-lint|CloudFormation / SAM の lint|mise install"
  "checkov|IaC のセキュリティ静的解析|mise install"
  "dot|Graphviz (構成図の描画エンジン)|brew install graphviz"
)

# 任意ツール(構成図生成。ステップ5で選定するため現時点では任意扱い)
OPTIONAL_TOOLS=(
  "inframap|Terraform から構成図生成|brew install inframap"
)

missing=0

echo "=== 必須ツール ==="
for entry in "${REQUIRED_TOOLS[@]}"; do
  IFS='|' read -r cmd desc install <<<"$entry"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "✅ %-10s %s\n" "$cmd" "$desc"
  else
    printf "❌ %-10s %s\n" "$cmd" "$desc"
    printf "   → インストール: %s\n" "$install"
    missing=$((missing + 1))
  fi
done

echo ""
echo "=== 任意ツール ==="
for entry in "${OPTIONAL_TOOLS[@]}"; do
  IFS='|' read -r cmd desc install <<<"$entry"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "✅ %-10s %s\n" "$cmd" "$desc"
  else
    printf "⚠️  %-10s %s (未インストールでも他の学習は可能)\n" "$cmd" "$desc"
    printf "   → インストール: %s\n" "$install"
  fi
done

echo ""
if [ "$missing" -eq 0 ]; then
  echo "必須ツールはすべて揃っています 🎉"
else
  echo "必須ツールが ${missing} 個不足しています。上記のコマンドでインストールしてください。"
  exit 1
fi
