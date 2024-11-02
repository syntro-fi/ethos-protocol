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
DEST_ABIS_INDEXER="../indexer/abis"
DEST_ABIS_FRONTEND="../frontend/src/contracts/abis"

# Create both destination directories
mkdir -p "$DEST_ABIS_INDEXER"
mkdir -p "$DEST_ABIS_FRONTEND"

# Copy to both destinations
cp -r "$SOURCE_ABIS"/* "$DEST_ABIS_INDEXER/"
cp -r "$SOURCE_ABIS"/* "$DEST_ABIS_FRONTEND/"
echo "All ABIs copied to: $DEST_ABIS_INDEXER and $DEST_ABIS_FRONTEND"

echo "Generation and copying completed successfully."

