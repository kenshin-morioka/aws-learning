#!/usr/bin/env bash
# Terraform の HCL を解析して AWS 構成図 (SVG) を生成するスクリプト。
#
#   terraform/*.tf → InfraMap (解析) → Graphviz (描画) → diagrams/terraform/architecture.svg
#
# AWS へは接続しない (HCL をローカルで解析するだけ)。
set -euo pipefail

cd "$(dirname "$0")/.."

# mise 管理のツールも見つけられるように PATH を追加
if command -v mise >/dev/null 2>&1; then
  PATH="$(mise bin-paths 2>/dev/null | tr '\n' ':')${PATH}"
fi

for cmd in inframap dot; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ $cmd が見つかりません。make check-tools を実行してください" >&2
    exit 1
  fi
done

OUT=diagrams/terraform/architecture.svg

# inframap はリソース間の参照 (依存関係) を解析して DOT 形式のグラフを出力する。
# それを Graphviz (dot) で SVG に描画する
inframap generate --hcl terraform/ | dot -Tsvg -o "$OUT"

echo "✅ 生成しました: $OUT"

# リソース未実装のうちは空のグラフになる
if inframap generate --hcl terraform/ | grep -qE '^\s*"' ; then
  :
else
  echo "   (terraform/ にまだリソースがないため空の図です。実装すると図が育ちます)"
fi
