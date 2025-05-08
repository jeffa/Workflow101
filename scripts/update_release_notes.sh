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

git --no-pager log --format=$'%h%x00%B%x00' "$before..$after" |
while IFS= read -r -d '' hash && IFS= read -r -d '' body; do
  in_tag=""        # holds “added” or “updated” or “deleted” once we see it
  block=""         # accumulates the text of that block

  # walk through each line of the commit message
  while IFS= read -r line || [[ -n $line ]]; do
    # 1) if we're in a block and this line is indented, append it
    if [[ -n $in_tag && $line =~ ^[[:space:]]+ ]]; then
      block+=$'\n'"$line"
      continue
    fi

    # 2) if we were in a block but this line is NOT indented, flush it now
    if [[ -n $in_tag ]]; then
      # flush the previous block
      section_header="### ${in_tag^}"
      # separate first line from any “rest”
      first_line="${block%%$'\n'*}"
      rest="${block#*$'\n'}"

      # bullet + SHA
      entry="- ${first_line} (${hash})"
      sed -i "/^${section_header}\$/a ${entry}" "$file"

      # any indented follow‐up lines
      if [[ $rest != "$block" ]]; then
        while IFS= read -r sub; do
          sed -i "/^${section_header}\$/a   ${sub}" "$file"
        done <<< "$rest"
      fi

      # reset for the next block
      in_tag=""
      block=""
    fi

    # 3) check for a new “added: …” / “updated: …” / “deleted: …”
    if [[ $line =~ ^(added|updated|deleted):[[:space:]]*(.*)$ ]]; then
      in_tag="${BASH_REMATCH[1]}"
      block="${BASH_REMATCH[2]}"
    fi
  done <<< "$body"

  # 4) if the message ended while we were in a block, flush it
  if [[ -n $in_tag ]]; then
    section_header="### ${in_tag^}"
    first_line="${block%%$'\n'*}"
    rest="${block#*$'\n'}"
    entry="- ${first_line} (${hash})"
    sed -i "/^${section_header}\$/a ${entry}" "$file"
    if [[ $rest != "$block" ]]; then
      while IFS= read -r sub; do
        sed -i "/^${section_header}\$/a   ${sub}" "$file"
      done <<< "$rest"
    fi
  fi

done
