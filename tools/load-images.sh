#!/bin/bash
IMAGES=$(find . -name "*tar" -depth 1)
while IFS= read -r image; do
	echo Importing $image
	docker load < $image
done <<< "$IMAGES"
