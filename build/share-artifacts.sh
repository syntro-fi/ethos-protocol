#!/bin/bash

# Run the generate-enums script
echo "Generating enums..."
bun build/generate-enums.ts

# Copy the generated ethos-enums.ts file
SOURCE_ENUMS="generated/ethos-enums.ts"
DEST_ENUMS="../indexer/src/ethos-enums.ts"
cp "$SOURCE_ENUMS" "$DEST_ENUMS"
echo "ethos-enums.ts copied to: $DEST_ENUMS"

# Copy ABIs
SOURCE_ABIS="out"
DEST_ABIS="../indexer/abis"

mkdir -p "$DEST_ABIS"

cp -r "$SOURCE_ABIS"/* "$DEST_ABIS/"
echo "All ABIs copied to: $DEST_ABIS"

echo "Generation and copying completed successfully."