// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {DistributionStrategy} from "ethos/DistributionStrategy.sol";

library MissionConfigHelper {
    function createTestConfig(address sponsor) internal view returns (MissionConfig memory) {
        return
            MissionConfig({
                sponsor: sponsor,
                // solhint-disable-next-line not-rely-on-time
                startDate: block.timestamp,
                // solhint-disable-next-line not-rely-on-time
                endDate: block.timestamp + 1 weeks,
                bountyAmount: 1000,
                distributionStrategy: DistributionStrategy.Equal,
                addtlDataCid: "QmTestAddtlDataCid"
            });
    }
}
