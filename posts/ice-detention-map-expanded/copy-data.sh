#!/bin/bash
# copy-data.sh
# Copies expanded map RDS files to this post's data/ directory.
# Run from the post directory: posts/ice-detention-map-expanded/
#
# Prerequisites:
#   In ice-detention project: tar_make(expanded_map_export)
#   Source dir: ~/Dropbox/R/ice-detention/data/expanded-map-export/

SRC="$HOME/Dropbox/R/ice-detention/data/expanded-map-export"
DEST="$(dirname "$0")/data"

mkdir -p "$DEST"

cp "$SRC/expanded_panel.rds"   "$DEST/"
cp "$SRC/expanded_presence.rds" "$DEST/"
cp "$SRC/expanded_geocoded.rds" "$DEST/"

echo "Copied 3 RDS files to $DEST/"
ls -lh "$DEST/"*.rds
