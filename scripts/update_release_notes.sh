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
git --no-pager log --format='%h %s' "$before..$after" | while read -r hash rest; do
  subject="$rest"
  if [[ "$subject" =~ ^(added|updated|deleted):[[:space:]]*(.*)$ ]]; then
    tag="${BASH_REMATCH[1]}"
    desc="${BASH_REMATCH[2]}"
    section_header="### ${tag^}"
    entry="- $desc ($hash)"
    # Insert entry under the corresponding section
    sed -i "/^${section_header}\$/a $entry" "$file"
  fi
done