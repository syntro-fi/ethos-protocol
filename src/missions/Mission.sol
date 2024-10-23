// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";

import {Roles} from "ethos/Roles.sol";

import {IMissionEligibility} from "./interfaces/IMissionEligibility.sol";
import {MissionConfig} from "./MissionConfig.sol";

error MissionNotEndedYet();
error NotImplemented();
error ApplicationAlreadySubmitted();
error ApplicationNotFound();
error ContributorNotEligible();

contract Mission is AccessControl {
    MissionConfig public config;
    IMissionEligibility public contributorEligibility;
    IMissionEligibility public verifierEligibility;
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
    event ApplicationApproved(address indexed applicant, address indexed remover);
    event ApplicationRejected(address indexed applicant, string reason, address indexed remover);
    event ContributorRemoved(address indexed contributor, address indexed remover);

    constructor(
        MissionConfig memory _config,
        address _contributorEligibility,
        address _verifierEligibility,
        address _owner
    ) {
        config = _config;
        token = IERC20(_config.tokenAddress);
        contributorEligibility = IMissionEligibility(_contributorEligibility);
        verifierEligibility = IMissionEligibility(_verifierEligibility);
        _setupInitialRoles(_owner, _config.sponsor);
    }

    function _setupInitialRoles(address _owner, address _sponsor) private {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(Roles.SPONSOR_ROLE, _owner);
        _grantRole(Roles.SPONSOR_ROLE, _sponsor);

        _setRoleAdmin(Roles.CONTRIBUTOR_ROLE, Roles.SPONSOR_ROLE);
        _setRoleAdmin(Roles.VERIFIER_ROLE, Roles.SPONSOR_ROLE);
    }

    function submitImpact(string memory ipfsHash) external onlyRole(Roles.CONTRIBUTOR_ROLE) {
        emit ImpactSubmitted(msg.sender, ipfsHash);
        revert NotImplemented();
    }

    function verifyImpact(uint256 impactId) external onlyRole(Roles.VERIFIER_ROLE) {
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

    function returnUnclaimedFunds() external view onlyRole(Roles.SPONSOR_ROLE) {
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp <= config.endDate) revert MissionNotEndedYet();
        revert NotImplemented();
    }

    function applyAsContributor() external {
        contributorEligibility.check(msg.sender, config);
        if (_enrollments.applications[msg.sender]) revert ApplicationAlreadySubmitted();
        if (_enrollments.contributors[msg.sender]) return;

        _enrollments.applications[msg.sender] = true;

        emit ApplicationSubmitted(msg.sender);
    }

    function acceptApplication(address applicant) external onlyRole(Roles.SPONSOR_ROLE) {
        if (!_enrollments.applications[applicant]) revert ApplicationNotFound();
        if (_enrollments.contributors[applicant]) return;

        _enrollments.contributors[applicant] = true;
        _grantRole(Roles.CONTRIBUTOR_ROLE, applicant);
        emit ApplicationApproved(applicant, msg.sender);
    }

    function rejectApplication(
        address applicant,
        string calldata reason
    ) external onlyRole(Roles.SPONSOR_ROLE) {
        if (!_enrollments.applications[applicant]) revert ApplicationNotFound();
        if (_enrollments.contributors[applicant]) return;

        emit ApplicationRejected(applicant, reason, msg.sender);
    }

    function removeContributor(address contributor) external onlyRole(Roles.SPONSOR_ROLE) {
        if (!hasRole(Roles.CONTRIBUTOR_ROLE, contributor)) return;

        _revokeRole(Roles.CONTRIBUTOR_ROLE, contributor);
        _enrollments.contributors[contributor] = false;
        emit ContributorRemoved(contributor, msg.sender);
    }
}
