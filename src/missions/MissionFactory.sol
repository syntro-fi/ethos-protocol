// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IEligibilityModuleManager} from "ethos/modules/eligibility/interfaces/IEligibilityModuleManager.sol";

import {MissionConfig} from "./MissionConfig.sol";
import {Mission} from "./Mission.sol";

error EligibilityModuleNotFound(IEligibilityModuleManager.UserType userType);
error InvalidTokenAddress();

contract MissionFactory is AccessControl {
    using SafeERC20 for IERC20;

    address public owner;
    address public allowedToken;

    event MissionCreated(address missionAddress);
    event AllowedTokenUpdated(address indexed newToken);

    constructor(address initialToken) {
        if (initialToken == address(0)) revert InvalidTokenAddress();
        allowedToken = initialToken;
        owner = msg.sender;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setAllowedToken(address newToken) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newToken == address(0)) revert InvalidTokenAddress();
        allowedToken = newToken;
        emit AllowedTokenUpdated(newToken);
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

        Mission newMission = new Mission(
            config,
            contributorEligibility,
            verifierEligibility,
            allowedToken,
            owner
        );

        emit MissionCreated(address(newMission));
        return address(newMission);
    }
}
