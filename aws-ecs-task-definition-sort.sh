#!/usr/bin/env sh

set -o errexit
set -o nounset
set -o pipefail

DEST_PATH=${1}

# Iterate all json files in dest folder
find "$DEST_PATH" -type f -name '*.json' -print0 | while read -d $'\0' file
do
  HAVE_ENV=$(jq -r '.containerDefinitions[].environment[]?' "$file")
  HAVE_SECRET=$(jq -r  '.containerDefinitions[].secrets[]?' "$file")

  # Sort top level elements
  cat <<< "$(jq -S . "$file")" > "$file"

  # Sort array `environment`
  if [ -n "$HAVE_ENV" ]; then
    cat <<< "$(jq -S '.containerDefinitions[].environment|=sort_by(.name)' "$file")" > "$file"
  fi

  # Sort array `secrets`
  if [ -n "$HAVE_SECRET" ] ; then
    cat <<< "$(jq -S '.containerDefinitions[].secrets|=sort_by(.name)' "$file")" > "$file"
  fi
done
