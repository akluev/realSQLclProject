#!/usr/bin/env python3
"""Reconcile numbered APEXlang page clones to a requested target count.

Usage:
    python scripts/apex/clone_apex_page.py <source_page> <count> [--start N] [--app-dir DIR]

Example:
    python scripts/apex/clone_apex_page.py 6 5
    -> keeps exactly five generated clones in pages 2001..2005
"""
import argparse
import random
import re
import sys
from pathlib import Path

DEFAULT_APP_DIR = "src/database/demo1/apex_apps/f106/demo1"
DEFAULT_START = 2001

PAGE_HEADER_RE = re.compile(r"^(page\s+)\d+(\s*\()", re.MULTILINE)
ALIAS_RE = re.compile(r"^(\s*alias:\s*)(\S+)", re.MULTILINE)
BIG_ID_RE = re.compile(r"(savedReportMappingIdentifier:\s*)(\d+)|(savedReport\s+)(\d+)(\s*\()")


def find_source_file(pages_dir: Path, page: int) -> Path:
    matches = sorted(pages_dir.glob(f"p{page:05d}-*.apx"))
    if not matches:
        raise SystemExit(f"No page file found for page {page} in {pages_dir}")
    if len(matches) > 1:
        raise SystemExit(f"Multiple page files matched for page {page}: {matches}")
    return matches[0]


def new_big_id() -> int:
    # APEX-style large numeric identifier, unique enough for local clones.
    return random.randint(10 ** 16, 10 ** 17 - 1)


def source_alias(source_file: Path) -> str:
    with source_file.open(encoding="utf-8", newline="") as source:
        match = ALIAS_RE.search(source.read())
    if match is None:
        raise SystemExit(f"Could not find 'alias:' line in {source_file}")
    return match.group(2).lower()


def remove_extra_clones(pages_dir: Path, alias: str, start: int, count: int) -> list[Path]:
    first_extra_page = start + count
    clone_name_re = re.compile(rf"^p(\d{{5}})-{re.escape(alias)}-(\d+)\.apx$")
    removed = []

    for page_file in pages_dir.glob(f"p*-{alias}-*.apx"):
        match = clone_name_re.fullmatch(page_file.name)
        if match is None:
            continue
        page_number = int(match.group(1))
        if page_number != int(match.group(2)) or page_number < first_extra_page:
            continue
        page_file.unlink()
        removed.append(page_file)

    return sorted(removed)


def clone_page(source_file: Path, source_page: int, new_page: int) -> Path:
    with source_file.open(encoding="utf-8", newline="") as source:
        text = source.read()

    text, count = PAGE_HEADER_RE.subn(rf"\g<1>{new_page}\g<2>", text, count=1)
    if count != 1:
        raise SystemExit(f"Could not find 'page {source_page} (' header in {source_file}")

    new_alias = None

    def alias_repl(m: re.Match) -> str:
        nonlocal new_alias
        new_alias = f"{m.group(2)}-{new_page}"
        return f"{m.group(1)}{new_alias}"

    text = ALIAS_RE.sub(alias_repl, text, count=1)
    if new_alias is None:
        raise SystemExit(f"Could not find 'alias:' line in {source_file}")

    def big_id_repl(m: re.Match) -> str:
        if m.group(1):
            return f"{m.group(1)}{new_big_id()}"
        return f"{m.group(3)}{new_big_id()}{m.group(5)}"

    text = BIG_ID_RE.sub(big_id_repl, text)

    # APEXlang requires the filename slug to match the page alias (lowercased).
    slug = new_alias.lower()
    dest_file = source_file.with_name(f"p{new_page:05d}-{slug}.apx")
    # newline="" preserves the source file's LF-only endings; APEXlang rejects CRLF.
    with dest_file.open("w", encoding="utf-8", newline="") as destination:
        destination.write(text)
    return dest_file


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_page", type=int, help="Existing page number to clone (e.g. 6)")
    parser.add_argument("count", type=int, help="Target number of generated clones (0 removes all clones)")
    parser.add_argument("--start", type=int, default=DEFAULT_START, help=f"First new page number (default {DEFAULT_START})")
    parser.add_argument("--app-dir", default=DEFAULT_APP_DIR, help=f"APEXlang app directory (default {DEFAULT_APP_DIR})")
    args = parser.parse_args()

    if args.count < 0:
        raise SystemExit("count must be a non-negative integer")

    pages_dir = Path(args.app_dir) / "pages"
    source_file = find_source_file(pages_dir, args.source_page)
    alias = source_alias(source_file)

    removed = remove_extra_clones(pages_dir, alias, args.start, args.count)
    for removed_file in removed:
        print(f"Removed {removed_file.relative_to(pages_dir.parent.parent)}")

    created = []
    for offset in range(args.count):
        new_page = args.start + offset
        existing = list(pages_dir.glob(f"p{new_page:05d}-*.apx"))
        if existing:
            print(f"Skipping page {new_page}: file already exists ({existing[0].name})", file=sys.stderr)
            continue
        dest_file = clone_page(source_file, args.source_page, new_page)
        created.append(dest_file)
        print(f"Created {dest_file.relative_to(pages_dir.parent.parent)}")

    print(
        f"Done. Created {len(created)} and removed {len(removed)} page(s) "
        f"for a target of {args.count} clone(s) from page {args.source_page}."
    )


if __name__ == "__main__":
    main()
