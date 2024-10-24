#!/bin/bash
set -e

# Build contracts
echo "Building contracts..."
forge build --skip test --skip script --force

# Share artifacts
echo "Sharing artifacts..."
npm run share-artifacts