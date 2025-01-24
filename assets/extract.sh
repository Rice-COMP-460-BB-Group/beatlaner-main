#!/usr/bin/env bash
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 file.gif [file2.gif ...]"
  exit 1
fi

for f in "$@"; do
  if [[ ! -f "$f" ]]; then
    echo "File not found: $f"
    continue
  fi

  basename="${f%.*}"

  convert "$f" -coalesce -transparent black "${basename}-%03d.png"
  echo "Created frames ${basename}-###.png from $f with black turned transparent."
done

