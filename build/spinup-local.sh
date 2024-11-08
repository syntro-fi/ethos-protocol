#!/bin/bash
set -e

# Start local node in the background
echo "Starting local node..."
anvil &

# Wait for the node to start
sleep 5

# Deploy contracts with specified target contract since we have a fake ERC20 contract in there
echo "Deploying contracts..."
forge script script/Deploy.s.sol:DeployScript --broadcast --fork-url http://localhost:8545

echo "Local deployment completed."