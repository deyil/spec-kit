#!/usr/bin/env bash
set -euo pipefail

# update-version.sh
# Update version in pyproject.toml (for release artifacts only)
# Usage: update-version.sh <version>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"

# Remove 'v' prefix for Python versioning
PYTHON_VERSION=${VERSION#v}

if [ -f "pyproject.toml" ]; then
  tmp_file=$(mktemp "${TMPDIR:-/tmp}/specify.XXXXXX")
  if sed "s/version = \".*\"/version = \"$PYTHON_VERSION\"/" pyproject.toml > "$tmp_file"; then
    mv "$tmp_file" pyproject.toml
    echo "Updated pyproject.toml version to $PYTHON_VERSION (for release artifacts only)"
  else
    rm -f "$tmp_file"
    echo "Error: failed to update pyproject.toml" >&2
    exit 1
  fi
else
  echo "Warning: pyproject.toml not found, skipping version update"
fi
