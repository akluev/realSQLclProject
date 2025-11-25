# Confluence → Markdown Conversion Guide

This document describes how to export pages from a Confluence Cloud space into GitHub-friendly Markdown along with embedded images.  
The process uses the Confluence REST API and a small Bash automation script.

---

## 1. Prerequisites

### 1.1. Confluence API Token

To access Confluence Cloud programmatically, you need an API token.

1. Open: https://id.atlassian.com/manage/api-tokens  
2. Click **Create API token**  
3. Name it (e.g., *Confluence Export*)  
4. Copy the token and store it securely  
5. Use the token with your Atlassian email as Basic Auth credentials

Example environment variables:

```bash
export BASE_URL="https://<your-domain>.atlassian.net"
export USERID="<your-email>"
export TOKEN="<your-api-token>"
```

---

## 1.2. Install jq

`jq` is used to parse JSON returned by the Confluence REST API.

### Windows / Git Bash (winget)

```bash
winget install --source winget --exact --id jqlang.jq
```

### macOS

```bash
brew install jq
```

### Linux

```bash
sudo apt install jq
```

---

## 1.3. Install Pandoc

Pandoc converts HTML extracted from Confluence into GitHub-compatible Markdown.

### Windows (winget)

```bash
winget install --source winget --exact --id JohnMacFarlane.Pandoc
```

### macOS

```bash
brew install pandoc
```

### Linux

```bash
sudo apt install pandoc
```

---

## 2. Script Overview

The repository includes a script:

```
export_page.sh
```

The script performs the following actions:

1. Downloads the page JSON (including rendered HTML) via Confluence REST API.  
2. Extracts the page title and sanitizes it for use as a Markdown filename.  
3. Parses and downloads any embedded images.  
4. Converts Confluence image references to local paths.  
5. Converts code block classes (`syntaxhighlighter-pre`) into `sql` so pandoc emits ```sql fences.  
6. Converts the final HTML into GitHub-flavored Markdown (GFM).  
7. Writes final outputs to:

```
docs/<sanitized-title>.md
docs/images/<downloaded images>
```

All intermediate artifacts are stored in:

```
tmp/page_<id>/
```

and can be ignored via `.gitignore`.

---

## 3. Running the Exporter

Export a Confluence page using its numeric page ID:

```bash
./export_page.sh 2561867784
```

You can find the page ID directly in the page URL:

```
https://<domain>.atlassian.net/wiki/spaces/.../pages/2561867784/Page+Title
```

After running the script, your directory structure will look like:

```
docs/
  images/
    <image files>
  <Page-Title>.md

tmp/
  page_<id>/
    page.json
    page.html
    images.txt
    ...
```

---

## 4. Notes and Recommendations

- The `tmp/` folder should be listed in `.gitignore`.  
- You can re-run the script on the same page safely — it overwrites only the relevant output.  
- Image filenames in Confluence already include timestamps/UUIDs, so storing all images in one folder is safe.  
- Code blocks are normalized to `sql` using HTML class replacement before conversion.  
- You can enhance the script to:
  - Export child pages recursively  
  - Rewrite Confluence links to relative GitHub links  
  - Detect and label code languages automatically  
  - Sanitize sensitive URLs or company names  

---

If you want, I can also generate:

- a **README.md** for the repo,  
- a **Confluence-formatted** version of this document,  
- or an extended **"batch exporter"** that crawls entire spaces.
