# ethos protocol

The basic idea is to be able to put funds into a bounty pool and distribute to a group of people
that **collectively** work towards a goal.

At the end of the campaign—or in intervals, if it’s an open ended campaign—their success will be
evaluated by **verifiers**. If the project is successful, the funds will be distributed among the
collective of impact creators.

**Verifiers** will also be rewarded for their contributions out of the bounty pool.

## Development

**Note: make sure your top level folder structure looks like this:**

```
ethos-protocol
├── contracts
├── frontend
└── indexer
```

### Building Contracts and Sharing Artifacts

To build the contracts and share the artifacts (generate enums, copy ABIs), run:

```bash
bun build:all
```

This script does the following:

1. Builds the contracts using Forge.
2. Generates enums from Solidity contracts in the `src` directory.
3. Copies the generated `ethos-enums.ts` file to `../indexer/src/`.
4. Copies all ABIs from the `out` directory to `../indexer/abis/`.

### Local Deployment

To start a local node, deploy the contracts, and stop the node, run:

```bash
bun spinup:local
```

This script does the following:

1. Starts a local Anvil node.
2. Deploys the contracts to the local node.
3. Stops the local node after deployment.

Make sure to run this script after making changes to the Solidity contracts or after compiling the contracts to ensure that the indexer has the latest enums and ABIs.
