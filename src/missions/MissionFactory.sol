// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IEligibilityModuleManager} from "ethos/modules/eligibility/interfaces/IEligibilityModuleManager.sol";

import {MissionConfig} from "./MissionConfig.sol";
import {Mission} from "./Mission.sol";

error EligibilityModuleNotFound(IEligibilityModuleManager.UserType userType);
error MissionNotFound();
error InsufficientFunds();

contract MissionFactory is AccessControl {
    using SafeERC20 for IERC20;

    address public owner;

    event MissionCreated(address missionAddress);

    constructor() {
        owner = msg.sender;
    }

    function createMission(
        MissionConfig memory config,
        address contributorEligibility,
        address verifierEligibility
    ) external returns (address) {
        if (contributorEligibility == address(0)) {
            revert EligibilityModuleNotFound(IEligibilityModuleManager.UserType.Contributor);
        }
        if (verifierEligibility == address(0)) {
            revert EligibilityModuleNotFound(IEligibilityModuleManager.UserType.Verifier);
        }

        IERC20 token = IERC20(config.tokenAddress);
        uint256 balance = token.balanceOf(msg.sender);
        if (balance < config.bountyAmount) revert InsufficientFunds();

        Mission newMission = new Mission(
            config,
            contributorEligibility,
            verifierEligibility,
            owner
        );

        token.safeTransferFrom(msg.sender, address(newMission), config.bountyAmount);

        emit MissionCreated(address(newMission));
        return address(newMission);
    }
}
