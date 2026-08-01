#!/usr/bin/env bash
# sync-wiki-automation.sh
#
# Re-renders changed QMD files in wiki-graph and copies the resulting HTML
# (and any companion _files/ directories) to quarto-website/wiki-automation/.
#
# Run from the quarto-website directory:
#   ./sync-wiki-automation.sh            # render only files newer than their HTML copy
#   ./sync-wiki-automation.sh --force    # render all files unconditionally
#   ./sync-wiki-automation.sh --dry-run  # show what would be rendered, do nothing
#
# Note: bolivia-muni-generator-en.qmd must render before bolivia-muni-infobox-en.qmd
# because the generator writes intermediate wikitext files that the infobox page reads.

set -euo pipefail

WIKI_GRAPH="$(cd "$(dirname "$0")/../wiki-graph" && pwd)"
DEST="$(cd "$(dirname "$0")/wiki-automation" && pwd)"

FORCE=false
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    --force)   FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# Files in render order (generator-en before infobox-en)
FILES=(
  bolivia-muni-generator-en
  bolivia-muni-infobox-en
  bolivia-muni-generator-es
  cpv2024-population-quickstatements
  bo-muni-flag-coat-wikidata-review
  pcode-crosswalk
  locator-maps-process
  bolivia-wikipedia-completeness
  bolivia-municipality-wikipedia
  wiki-cleanup-bolivia-municipalities
)

needs_render() {
  local base="$1"
  local src="$WIKI_GRAPH/$base.qmd"
  local dst="$DEST/$base.html"
  # Render if destination doesn't exist or source is newer
  [[ ! -f "$dst" ]] || [[ "$src" -nt "$dst" ]]
}

copy_outputs() {
  local base="$1"
  cp "$WIKI_GRAPH/$base.html" "$DEST/$base.html"
  if [[ -d "$WIKI_GRAPH/${base}_files" ]]; then
    rm -rf "$DEST/${base}_files"
    cp -r "$WIKI_GRAPH/${base}_files" "$DEST/${base}_files"
  fi
}

rendered=0
skipped=0

for base in "${FILES[@]}"; do
  src="$WIKI_GRAPH/$base.qmd"

  if ! $FORCE && ! needs_render "$base"; then
    echo "  skip  $base (up to date)"
    ((skipped++)) || true
    continue
  fi

  if $DRY_RUN; then
    echo "  would render  $base.qmd"
    ((rendered++)) || true
    continue
  fi

  echo "→ rendering $base.qmd ..."
  (cd "$WIKI_GRAPH" && quarto render "$base.qmd" --quiet)
  copy_outputs "$base"
  echo "  ✓ copied $base.html to wiki-automation/"
  ((rendered++)) || true
done

echo ""
if $DRY_RUN; then
  echo "Dry run: $rendered file(s) would be rendered, $skipped skipped."
else
  echo "Done: $rendered file(s) rendered and copied, $skipped skipped."
fi
