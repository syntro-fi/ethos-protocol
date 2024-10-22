// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IMissionEligibility} from "ethos/modules/interfaces/IMissionEligibility.sol";

import {MissionRoleManager} from "./MissionRoleManager.sol";
import {MissionConfig} from "./MissionConfig.sol";

error MissionNotEndedYet();
error NotImplemented();
error ApplicationAlreadySubmitted();
error ApplicationNotFound();
error ContributorNotEligible();

contract Mission is MissionRoleManager {
    MissionConfig public config;
    IMissionEligibility public contributorEligibilityModule;
    IERC20 public token;

    struct EnrollmentState {
        mapping(address => bool) applications;
        mapping(address => bool) contributors;
    }

    EnrollmentState private _enrollments;

    event ImpactSubmitted(address indexed contributor, string ipfsHash);
    event ImpactVerified(address indexed verifier, uint256 impactId);
    event DisputeRaised(uint256 indexed impactId, string reason);
    event RewardsDistributed(uint256 impactId, address indexed recipient, uint256 amount);
    event UnclaimedFundsReturned(address indexed sponsor, uint256 amount);
    event ApplicationSubmitted(address indexed applicant);
    event ApplicationApproved(address indexed applicant, address indexed manager);
    event ApplicationRejected(address indexed applicant, string reason, address indexed manager);

    constructor(
        MissionConfig memory _config,
        address _authModule,
        address _contributorEligibilityModule,
        address _owner
    ) MissionRoleManager(_authModule) {
        config = _config;
        token = IERC20(_config.tokenAddress);
        contributorEligibilityModule = IMissionEligibility(_contributorEligibilityModule);

        // Set up initial roles with the provided owner
        _setupInitialRoles(_owner, _config.sponsor);
    }

    function submitImpact(string memory ipfsHash) external onlyRole(CONTRIBUTOR_ROLE) {
        emit ImpactSubmitted(msg.sender, ipfsHash);
        revert NotImplemented();
    }

    function verifyImpact(uint256 impactId) external onlyRole(VERIFIER_ROLE) {
        emit ImpactVerified(msg.sender, impactId);
        revert NotImplemented();
    }

    function raiseDispute(uint256 impactId, string memory reason) external {
        emit DisputeRaised(impactId, reason);
        revert NotImplemented();
    }

    function distributeRewards() external pure {
        revert NotImplemented();
    }

    function returnUnclaimedFunds() external view onlyRole(SPONSOR_ROLE) {
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp <= config.endDate) revert MissionNotEndedYet();
        revert NotImplemented();
    }

    function applyAsContributor() external {
        _authenticateContributor(msg.sender);
        contributorEligibilityModule.check(msg.sender, config);
        if (_enrollments.applications[msg.sender]) revert ApplicationAlreadySubmitted();
        if (_enrollments.contributors[msg.sender]) return;

        _enrollments.applications[msg.sender] = true;

        emit ApplicationSubmitted(msg.sender);
    }

    function acceptApplication(address applicant) external onlyRole(MANAGER_ROLE) {
        if (!_enrollments.applications[applicant]) revert ApplicationNotFound();
        if (_enrollments.contributors[applicant]) return;

        _enrollments.contributors[applicant] = true;
        _grantContributorRole(applicant);
        emit ApplicationApproved(applicant, msg.sender);
    }

    function rejectApplication(address applicant, string calldata reason) external onlyRole(MANAGER_ROLE) {
        if (!_enrollments.applications[applicant]) revert ApplicationNotFound();
        if (_enrollments.contributors[applicant]) return;

        emit ApplicationRejected(applicant, reason, msg.sender);
    }
}
