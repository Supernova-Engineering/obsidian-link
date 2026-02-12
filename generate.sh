#!/usr/bin/env bash
# generate.sh — Scan an Obsidian vault and create redirect HTML pages
# Usage: ./generate.sh /path/to/vault [vault-name]

set -euo pipefail

VAULT_DIR="${1:?Usage: ./generate.sh /path/to/vault [vault-name]}"
VAULT_NAME="${2:-seb-obsidian}"
OUT_DIR="$(cd "$(dirname "$0")" && pwd)/docs"
BASE_URL="https://supernova-engineering.github.io/obsidian-link"

# Clean previous output
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# Generate index page
cat > "$OUT_DIR/index.html" <<'INDEXEOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Obsidian Link Redirector</title>
  <style>
    body { font-family: -apple-system, system-ui, sans-serif; max-width: 600px; margin: 80px auto; padding: 0 20px; color: #333; }
    h1 { font-size: 1.4em; }
    code { background: #f0f0f0; padding: 2px 6px; border-radius: 3px; font-size: 0.9em; }
    a { color: #7c3aed; }
  </style>
</head>
<body>
  <h1>📎 Obsidian Link Redirector</h1>
  <p>This service redirects HTTPS links to <code>obsidian://</code> URIs.</p>
  <p>Append a note path to this URL to open it in Obsidian:</p>
  <p><code>BASE_URL/path/to/note</code></p>
</body>
</html>
INDEXEOF

sed -i '' "s|BASE_URL|${BASE_URL}|g" "$OUT_DIR/index.html" 2>/dev/null || \
sed -i "s|BASE_URL|${BASE_URL}|g" "$OUT_DIR/index.html"

# Count generated pages
count=0

# Find all .md files and generate redirect pages
while IFS= read -r -d '' mdfile; do
  # Get relative path without .md extension
  relpath="${mdfile#$VAULT_DIR/}"
  relpath="${relpath%.md}"

  # Skip hidden files/dirs and .obsidian
  case "$relpath" in
    .obsidian*|.*) continue ;;
  esac

  # Create output directory structure
  outpath="$OUT_DIR/$relpath"
  mkdir -p "$(dirname "$outpath")"

  # URL-encode the file path for obsidian:// URI
  encoded_path=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$relpath")

  # Obsidian URI
  obsidian_uri="obsidian://open?vault=${VAULT_NAME}&file=${encoded_path}"

  # Generate redirect HTML
  cat > "${outpath}.html" <<HTMLEOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Opening in Obsidian...</title>
  <meta http-equiv="refresh" content="0;url=${obsidian_uri}">
  <style>
    body { font-family: -apple-system, system-ui, sans-serif; max-width: 500px; margin: 80px auto; padding: 0 20px; text-align: center; color: #333; }
    a { color: #7c3aed; text-decoration: none; font-weight: 500; }
    a:hover { text-decoration: underline; }
    .note-name { font-size: 0.9em; color: #666; margin-top: 8px; }
  </style>
</head>
<body>
  <h2>📎 Opening in Obsidian...</h2>
  <p>If nothing happened, <a href="${obsidian_uri}">tap here to open</a>.</p>
  <p class="note-name">${relpath}</p>
  <script>window.location.href = "${obsidian_uri}";</script>
</body>
</html>
HTMLEOF

  count=$((count + 1))
done < <(find "$VAULT_DIR" -name '*.md' -print0)

echo "Generated $count redirect pages in $OUT_DIR"
