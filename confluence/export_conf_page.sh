#!/usr/bin/env bash

set -e
trap 'c=$?; [ $c -ne 0 ] && echo "FAILED with code $c"' EXIT


# Resolve the directory where this script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Move to repo root (script is inside repo_root/confluence/)
repo_root="$(cd "${script_dir}/.." && pwd)"
cd "$repo_root"

if [ ! -d "${repo_root}/docs" ]; then
  echo "[error] docs/ folder not found — script must run inside the repo root."
  exit 1
fi

#echo "[info] Running from repository root: $repo_root"


#############################################
# Validate input
#############################################
if [ -z "$1" ]; then
  echo "Usage: $0 <PAGE_ID>"
  exit 1
fi

page_id="$1"

if [ -z "$BASE_URL" ] || [ -z "$USERID" ] || [ -z "$TOKEN" ]; then
  echo "ERROR: Please export BASE_URL, USERID, and TOKEN first."
  echo ""
  echo "Example:"
  echo "  export BASE_URL=\"https://yourtenant.atlassian.net\""
  echo "  export USERID=\"you@example.com\""
  echo "  export TOKEN=\"your_api_token\""
  exit 1
fi


#############################################
# Prepare directories
#############################################
tmpdir="tmp/page_${page_id}"
outdir="docs"


outdir="$(cd "$outdir" && pwd)"
imgdir="${outdir}/images"
mkdir -p "$imgdir"
 
mkdir -p "$tmpdir"
cd "$tmpdir"

# Working filenames
json_file="page.json"
html_file="page.html"
fixed_html="page_fixed.html"
img_list="images.txt"

echo "============================================"
echo " Exporting Confluence Page ID: $page_id"
echo " Temporary directory: $tmpdir"
echo " Output Markdown directory: $outdir"
echo " Output image directory: $imgdir"
echo "============================================"


#############################################
# 1. Download JSON
#############################################
echo "[1/7] Downloading JSON..."
curl -s -u "${USERID}:${TOKEN}" \
  "${BASE_URL}/wiki/rest/api/content/${page_id}?expand=body.view" \
  -o "$json_file"


#############################################
# 2. Extract & sanitize title
#############################################
echo "[2/7] Extracting title..."
raw_title=$(jq -r '.title' "$json_file")

safe_title=$(printf "%s" "$raw_title" \
    | sed 's/[\/:*?"<>|]/-/g' \
    | sed 's/ /-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//' \
    | sed 's/-$//')

md_file="${safe_title}.md"

echo "Page title: $raw_title"
echo "Markdown output file: $md_file"


#############################################
# 3. Extract HTML
#############################################
echo "[3/7] Extracting HTML..."
jq -r '.body.view.value' "$json_file" > "$html_file"


#############################################
# 4. Extract full-size images
#############################################
echo "[4/7] Extracting large image URLs..."

grep -o 'data-image-src="[^"]*' "$html_file" \
  | sed 's/data-image-src="//' > "$img_list" || true

img_count=$(wc -l < "$img_list" | tr -d ' ')
echo "Found $img_count images."


#############################################
# 5. Download images
#############################################
echo "[5/7] Downloading images..."

while IFS= read -r img; do
  [ -z "$img" ] && continue

  clean_url=$img #$(printf '%s\n' "$img" | sed 's/&amp;/\&/g')
  file_name=$(basename "${clean_url%%\?*}")

  echo "  - ${imgdir}/${file_name}"

  curl -s -L -u "${USERID}:${TOKEN}" \
    "$clean_url" -o "${file_name}"
  
  cp "${file_name}" "${imgdir}/${file_name}"

done < "$img_list"


#############################################
# 6. Rewrite HTML URLs → local images
#############################################
echo "[6/7] Rewriting image references..."

cp "$html_file" "$fixed_html"

while IFS= read -r img; do
  [ -z "$img" ] && continue

  file_name=$(basename "${img%%\?*}")

  # Replace attachment URLs
  sed "s|$img|images/$file_name|g" "$fixed_html" > tmp && mv tmp "$fixed_html"

  # Replace thumbnail variants
  thumb_pattern="${BASE_URL//\//\\/}\/wiki\/download\/thumbnails\/[^\" ]*${file_name}[^\" ]*"
  sed -E "s|$thumb_pattern|images/$file_name|g" "$fixed_html" > tmp && mv tmp "$fixed_html"

done < "$img_list"


#############################################
# 6b. Fix Confluence code blocks → ```sql
#############################################

echo "[6b] Fixing code blocks..."

# Convert <pre class="syntaxhighlighter-pre">...</pre> to fenced code blocks
sed  \
  's/class="syntaxhighlighter-pre"/class="sql"/g' \
  "$fixed_html" > tmp && mv tmp "$fixed_html"

#############################################
# 7. Convert HTML → Markdown
#############################################
echo "[7/7] Converting HTML to Markdown..."

pandoc "$fixed_html" -f html -t gfm --wrap=preserve \
  -o "${outdir}/${md_file}"

echo ""
echo "============================================"
echo " Export complete!"
echo " Markdown file:  ${outdir}/${md_file}"
echo " Images in:       ${imgdir}/"
echo "============================================"
