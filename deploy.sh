#!/usr/bin/env bash
set -e

BASE_URL="https://koheitokura.github.io/"
MSG="${1:-Update site}"

git checkout main

# ソース側を保存
git add .
if ! git diff --cached --quiet; then
  git commit -m "$MSG"
  git push origin main
else
  echo "No source changes to commit."
fi

# 公開用HTMLを生成
rm -rf public
hugo --gc --minify --baseURL "$BASE_URL"
touch public/.nojekyll

# gh-pagesブランチへ公開
REPO_URL=$(git remote get-url origin)
TMPDIR=$(mktemp -d)

cp -a public/. "$TMPDIR"/

(
  cd "$TMPDIR"
  git init
  git checkout -b gh-pages
  git add .
  git commit -m "Deploy site"
  git remote add origin "$REPO_URL"
  git push -f origin gh-pages
)

rm -rf "$TMPDIR"

echo "Deployed: $BASE_URL"
