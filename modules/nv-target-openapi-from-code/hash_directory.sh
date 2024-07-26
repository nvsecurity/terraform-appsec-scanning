#!/bin/bash

DIRECTORY=$1

if [ -z "$DIRECTORY" ]; then
  echo '{"error": "Directory path is required"}'
  exit 1
fi

HASH=$(find "$DIRECTORY" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{ print $1 }')

echo "{\"hash\": \"$HASH\"}"
