// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DistributionStrategy} from "ethos/DistributionStrategy.sol";

struct MissionConfig {
    address sponsor;
    uint256 startDate;
    uint256 endDate;
    address tokenAddress;
    uint256 bountyAmount;
    DistributionStrategy distributionStrategy;
    string addtlDataCid;
}

error InvalidSponsorAddress();
error MissingAddtlDataCid();
error InvalidDateRange();
error InvalidTokenAddress();
error InvalidBountyAmount();

library MissionConfigValidator {
    function validate(MissionConfig memory config) internal pure {
        if (config.sponsor == address(0)) revert InvalidSponsorAddress();
        if (bytes(config.addtlDataCid).length == 0) revert MissingAddtlDataCid();
        if (config.startDate >= config.endDate) revert InvalidDateRange();
        if (config.tokenAddress == address(0)) revert InvalidTokenAddress();
        if (config.bountyAmount == 0) revert InvalidBountyAmount();
    }
}
