#!/usr/bin/env bash
# SAM テンプレートから構成図 (Mermaid) を生成するスクリプト。
#
#   sam/template.yaml → cfn-diagram (解析) → diagrams/sam/architecture.md
#
# Mermaid 形式は GitHub の README / Markdown 上でそのまま図として描画される。
# AWS へは接続しない (テンプレートをローカルで解析するだけ)。
set -euo pipefail

cd "$(dirname "$0")/.."

# mise 管理のツールも見つけられるように PATH を追加
if command -v mise >/dev/null 2>&1; then
  PATH="$(mise bin-paths 2>/dev/null | tr '\n' ':')${PATH}"
fi

if ! command -v cfn-dia >/dev/null 2>&1; then
  echo "❌ cfn-dia が見つかりません。make check-tools を実行してください" >&2
  exit 1
fi

OUT=diagrams/sam/architecture.md

cfn-dia mermaid -t sam/template.yaml -o "$OUT"

echo "✅ 生成しました: $OUT"
