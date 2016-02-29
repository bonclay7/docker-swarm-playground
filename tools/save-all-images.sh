#!/bin/bash

IMAGES=$(docker images | grep 'tick' | awk '{print $1}')

while IFS= read -r line; do
	FILENAME=$(printf '%s' "$line")
	echo "Saving image \"$line:latest\" to \"$FILENAME.tar\"..."
	docker save "$line:latest" > "$FILENAME.tar"
done <<< "$IMAGES"
