#!/bin/bash
# copy-data.sh
# Copies pre-computed facility directory data to this post's data/ directory.
# Run from the post directory: posts/facility-directory/
#
# Prerequisites:
#   In ice-detention project: tar_make(facility_directory_export)
#   Source dir: ~/Dropbox/R/ice-detention/data/facility-directory-export/

SRC="$HOME/Dropbox/R/ice-detention/data/facility-directory-export"
DEST="$(dirname "$0")/data"

mkdir -p "$DEST"

cp "$SRC/facility_tbl.rds" "$DEST/"

echo "Copied facility_tbl.rds to $DEST/"
ls -lh "$DEST/"*.rds
