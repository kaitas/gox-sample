#!/bin/bash
# WordPress REST API コンテンツバックアップスクリプト
# Usage: ./scripts/wp-backup.sh
#
# WP REST API 経由で公開コンテンツ(posts, pages, events, news, media)を
# JSON形式でバックアップします。DBへの直接アクセスは不要です。

set -e

SITE_URL="https://cryptoloungegox.com"
API_BASE="${SITE_URL}/wp-json/wp/v2"
BACKUP_DIR="backup/$(date +%Y-%m-%d)"
PER_PAGE=100

mkdir -p "$BACKUP_DIR"

echo "=== WordPress REST API バックアップ ==="
echo "サイト: $SITE_URL"
echo "出力先: $BACKUP_DIR"
echo ""

# 各エンドポイントからデータを取得
endpoints=("posts" "pages" "event" "news" "media" "categories" "tags")

for endpoint in "${endpoints[@]}"; do
  echo -n "[$endpoint] 取得中..."

  page=1
  tmpfile=$(mktemp)
  echo "[" > "$tmpfile"
  first=true
  total=0

  while true; do
    pagefile=$(mktemp)
    http_code=$(curl -s -w "%{http_code}" -o "$pagefile" \
      "${API_BASE}/${endpoint}?per_page=${PER_PAGE}&page=${page}&_embed" 2>/dev/null)

    if [ "$http_code" != "200" ]; then
      rm -f "$pagefile"
      if [ "$page" -eq 1 ]; then
        echo " スキップ (HTTP $http_code)"
      fi
      break
    fi

    count=$(python3 -c "import json; print(len(json.load(open('$pagefile'))))" 2>/dev/null || echo "0")

    if [ "$count" -eq 0 ]; then
      rm -f "$pagefile"
      break
    fi

    # JSON配列の中身だけ追記（先頭の [ と末尾の ] を除去）
    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> "$tmpfile"
    fi
    python3 -c "
import json
with open('$pagefile') as f:
    items = json.load(f)
for i, item in enumerate(items):
    if i > 0:
        print(',')
    print(json.dumps(item, ensure_ascii=False))
" >> "$tmpfile"

    total=$((total + count))
    rm -f "$pagefile"
    page=$((page + 1))

    if [ "$count" -lt "$PER_PAGE" ]; then
      break
    fi
  done

  echo "]" >> "$tmpfile"

  if [ "$total" -gt 0 ]; then
    python3 -m json.tool "$tmpfile" > "$BACKUP_DIR/${endpoint}.json"
    echo " ${total}件 -> ${BACKUP_DIR}/${endpoint}.json"
  fi

  rm -f "$tmpfile"
done

# サマリー
echo ""
echo "=== バックアップ完了 ==="
echo "出力先: $BACKUP_DIR/"
ls -lh "$BACKUP_DIR/"
echo ""
echo "※ これはREST API経由の公開コンテンツのバックアップです。"
echo "※ 下書き・非公開記事・プラグイン設定・テーマ設定等は含まれません。"
echo "※ 完全なDBバックアップにはサーバーへのSSHアクセスまたはWPプラグインが必要です。"
