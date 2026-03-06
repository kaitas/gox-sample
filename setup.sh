#!/bin/bash
# GOX Site Setup Script for Claude Code
# このスクリプトを実行すると、プロジェクトのセットアップからビルドまで完了します

set -e

echo "🚀 GOX Site セットアップ開始..."

# Node.js確認
if ! command -v node &> /dev/null; then
    echo "❌ Node.jsがインストールされていません"
    exit 1
fi

echo "✅ Node.js $(node -v) 検出"

# 依存関係インストール
echo "📦 依存関係をインストール中..."
npm install

# ビルド
echo "🔨 サイトをビルド中..."
npm run build

echo ""
echo "✅ ビルド完了！"
echo ""
echo "📁 出力ディレクトリ: ./dist/"
echo ""
echo "次のステップ:"
echo "  1. ローカルプレビュー: npm run preview"
echo "  2. Cloudflare Pages デプロイ: wrangler pages deploy dist --project-name=gox-site"
echo ""
echo "詳細は AGENTS.md を参照してください"
