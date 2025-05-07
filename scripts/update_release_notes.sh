#!/usr/bin/env bash
set -euo pipefail

# Script to update release notes based on commit messages.
# Usage: scripts/update_release_notes.sh <previous_commit> <current_commit>

before=$1
after=$2
file="RELEASE_NOTES.md"

# Initialize release notes file if it doesn't exist
if [ ! -f "$file" ]; then
  cat <<EOF > "$file"
# Release Notes

All notable changes to this project will be documented in this file.

## Unreleased

### Added

### Updated

### Deleted

EOF
fi

# Scan commit messages for tags and insert entries
# git log --format:  hash<NUL>body<NUL> for each commit
git --no-pager log --format=$'%h%x00%B%x00' "$before..$after" |
while IFS= read -r -d '' hash && IFS= read -r -d '' body; do
  # now $hash is the short SHA
  #    $body is the full commit message (possibly multi‐line)

  # scan each line in the body for our tags
  while IFS= read -r line; do
    if [[ "$line" =~ ^(added|updated|deleted):[[:space:]]*(.*)$ ]]; then
      tag="${BASH_REMATCH[1]}"
      desc="${BASH_REMATCH[2]}"
      # uppercase first char of the tag for the Markdown header
      section_header="### ${tag^}"
      entry="- $desc ($hash)"
      # insert right after the matching section in $file
      sed -i "/^${section_header}\$/a $entry" "$file"
    fi
  done <<<"$body"
done
