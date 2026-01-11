#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <redirects-yaml> [site-output-dir]
redirects-yaml: YAML file with a top-level 'redirects:' list of mappings 'old' and 'new'
site-output-dir: directory with built site (default: _site)
Example YAML:
redirects:
  - old: /old-page/
    new: /new-page/
USAGE
  exit 2
}

if [ "$#" -lt 1 ]; then usage; fi

MAPFILE="$1"
SITE_DIR="${2:-_site}"

if [ ! -f "$MAPFILE" ]; then
  echo "Redirects file not found: $MAPFILE" >&2
  exit 1
fi

mkdir -p "$SITE_DIR"

# Preprocess the YAML to remove surrounding quotes in values (handles "..." and '...')
# Then parse with plain awk (portable on macOS)
parse_redirects() {
  sed -E \
    -e 's/:[[:space:]]*"([^"]*)"/: \1/' \
    -e "s/:[[:space:]]*'([^']*)'/: \\1/" \
    "$MAPFILE" | \
  awk '
    # trim function
    function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
    function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
    function trim(s) { return rtrim(ltrim(s)) }

    BEGIN { old=""; new=""; }

    {
      line = $0
      # strip leading whitespace
      sub(/^[ \t]+/, "", line)

      # skip empty lines and the top-level "redirects:" key (possibly with - or whitespace)
      if (line == "" || line ~ /^[#[:space:]-]*redirects:$/) next

      # remove leading "- " from list items (if present)
      if (line ~ /^- /) sub(/^- +/, "", line)

      # find first colon; if none, skip
      colon = index(line, ":")
      if (colon == 0) next

      key = substr(line, 1, colon-1)
      val = substr(line, colon+1)

      key = trim(key)
      val = trim(val)

      if (key == "old") {
        old = val
      } else if (key == "new") {
        new = val
      }

      # if we have a complete pair, print and reset
      if (old != "" && new != "") {
        print old " " new
        old = ""; new = ""
      }
    }

    END {
      if (old != "" && new != "") print old " " new
    }
  '
}

# Iterate parsed pairs and emit redirect files
while IFS= read -r pair; do
  # pair format: "<old> <new>" (first token old, rest new)
  old="${pair%% *}"
  new="${pair#* }"

  if [ -z "$old" ] || [ -z "$new" ]; then
    echo "Skipping invalid pair: '$pair'" >&2
    continue
  fi

  # normalize leading slash off for file paths inside SITE_DIR
  path="${old#/}"

  # decide whether to create a directory/index.html or a file
  if [[ "$path" == */ ]] || [[ "$path" != *.* ]]; then
    outdir="$SITE_DIR/$path"
    mkdir -p "$outdir"
    dest="$outdir/index.html"
  else
    mkdir -p "$(dirname "$SITE_DIR/$path")"
    dest="$SITE_DIR/$path"
  fi

  cat > "$dest" <<EOF
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="refresh" content="0; url=${new}">
    <link rel="canonical" href="${new}">
    <title>Redirecting…</title>
  </head>
  <body>
    Redirecting to <a href="${new}">${new}</a>.
    <script>location.replace("${new}");</script>
  </body>
</html>
EOF

  echo "Created redirect: $dest -> $new"
done < <(parse_redirects)