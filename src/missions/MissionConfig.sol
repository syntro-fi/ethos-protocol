// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DistributionStrategy} from "ethos/DistributionStrategy.sol";

struct MissionConfig {
    address sponsor;
    string description; // TODO: move to IPFS or EAS
    uint256 startDate;
    uint256 endDate;
    address tokenAddress;
    uint256 bountyAmount;
    DistributionStrategy distributionStrategy;
}

error InvalidSponsorAddress();
error EmptyDescription();
error InvalidDateRange();
error InvalidTokenAddress();
error InvalidBountyAmount();

library MissionConfigValidator {
    function validate(MissionConfig memory config) internal pure {
        if (config.sponsor == address(0)) revert InvalidSponsorAddress();
        if (config.startDate >= config.endDate) revert InvalidDateRange();
        if (config.tokenAddress == address(0)) revert InvalidTokenAddress();
        if (config.bountyAmount == 0) revert InvalidBountyAmount();
    }
}
