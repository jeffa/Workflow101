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

#  * `mapfile -t lines <<<"$body"` splits your multi‐line commit message into a Bash array.
#  * We iterate that array by index so that when we do our “collect indented lines” loop we can advance the index past them without losing our place.
#  * A line matches `^(added|updated|deleted):\s*(.*)$` → that captures your tag and the rest of that line.
#  * The inner `while` pulls in any following lines that start with whitespace (you treat those as part of the same entry).
#  * We then insert the entire block under `### Added`, `### Updated` or `### Deleted` (depending on the tag) using `sed -i '/^### Added$/a …'`.
#  * The very first line of the block becomes the bullet `- … (hash)`.  Any extra lines are prefixed with two spaces so they stay attached to that bullet in Markdown.

# Scan commit messages for tags and insert entries
git --no-pager log --format=$'%h%x00%B%x00' "$before..$after" |
while IFS= read -r -d '' hash && IFS= read -r -d '' body; do
  # split the commit message into lines
  mapfile -t lines <<<"$body"
  # walk through the lines by index
  for (( i = 0; i < ${#lines[@]}; )); do
    line="${lines[i]}"
    if [[ "$line" =~ ^(added|updated|deleted):[[:space:]]*(.*)$ ]]; then
      tag="${BASH_REMATCH[1]}"
      section_header="### ${tag^}"
      # start the block with everything after "tag:"
      block="${BASH_REMATCH[2]}"
      (( i++ ))
      # pull in any following lines that are indented
      while (( i < ${#lines[@]} )) && [[ "${lines[i]}" =~ ^[[:space:]]+ ]]; do
        block+=$'\n'"${lines[i]}"
        (( i++ ))
      done

      # now emit the block under the right header in your release-notes file
      #
      # First line becomes the bullet with the SHA:
      first="${block%%$'\n'*}"
      entry="- ${first} (${hash})"
      sed -i "/^${section_header}\$/a ${entry}" "$file"

      # Any subsequent lines in the block get indented two spaces
      rest="${block#*$'\n'}"
      if [[ "$rest" != "$block" ]]; then
        while IFS= read -r subline; do
          # note the two-space prefix for a sub‐item in Markdown
          sed -i "/^${section_header}\$/a   ${subline}" "$file"
        done <<<"$rest"
      fi

    else
      (( i++ ))
    fi
  done
done
