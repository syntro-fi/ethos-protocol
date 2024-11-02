#!/bin/bash

jq -r '.transactions[] | select(.transactionType == "CREATE") | "\(.contractName): \(.contractAddress)"' broadcast/Deploy.s.sol/31337/run-latest.json
