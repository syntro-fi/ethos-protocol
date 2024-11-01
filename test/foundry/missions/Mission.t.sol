// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {Mission, ApplicationAlreadySubmitted, ApplicationNotFound, MissionNotEndedYet} from "ethos/missions/Mission.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {DistributionStrategy} from "ethos/DistributionStrategy.sol";
import {NotEligible} from "ethos/Errors.sol";
import {Roles} from "ethos/Roles.sol";

import {FakeERC20} from "./FakeERC20.sol";
import {FakeMissionEligibility} from "./FakeMissionEligibility.sol";
import {MissionConfigHelper} from "./MissionConfigHelper.sol";

contract MissionTest is Test {
    Mission public mission;
    FakeERC20 public token;
    FakeMissionEligibility public contributorEligibility;
    FakeMissionEligibility public verifierEligibility;
    address public sponsor;
    address public manager;
    address public contributor;
    address public verifier;
    address public missionFactoryOwner;

    function setUp() public {
        missionFactoryOwner = address(this); // The test contract deploys the MissionFactory
        sponsor = address(1);
        contributor = address(3);
        verifier = address(4);

        token = new FakeERC20("Test Token", "TEST");
        contributorEligibility = new FakeMissionEligibility();
        verifierEligibility = new FakeMissionEligibility();
        MissionConfig memory config = MissionConfigHelper.createTestConfig(sponsor, address(token));

        // Ensure the sponsor has enough tokens to fund the mission
        token.mint(sponsor, config.bountyAmount);

        mission = new Mission(
            config,
            address(contributorEligibility),
            address(verifierEligibility),
            missionFactoryOwner // Pass the MissionFactory owner (this test contract)
        );

        // Approve the mission contract to spend tokens on behalf of the sponsor
        vm.prank(sponsor);
        token.approve(address(mission), config.bountyAmount);

        setupRoles();
    }

    function setupRoles() public {
        mission.grantRole(Roles.SPONSOR_ROLE, sponsor);
    }

    function testInitialRoles() public {
        assertTrue(mission.hasRole(mission.DEFAULT_ADMIN_ROLE(), missionFactoryOwner));
        assertTrue(mission.hasRole(Roles.SPONSOR_ROLE, missionFactoryOwner));
        assertTrue(mission.hasRole(Roles.SPONSOR_ROLE, sponsor));
    }

    function testConstructor() public {
        (
            address configSponsor,
            uint256 configStartDate,
            uint256 configEndDate,
            address configTokenAddress,
            uint256 configBountyAmount,
            DistributionStrategy configDistributionStrategy,
            string memory configAddtlDataCid
        ) = mission.config();
        assertEq(configSponsor, sponsor);
        assertEq(configTokenAddress, address(token));
        assertEq(address(mission.contributorEligibility()), address(contributorEligibility));
        assertEq(configBountyAmount, 1000);
        assertEq(uint(configDistributionStrategy), uint(DistributionStrategy.Equal));
        assertEq(configAddtlDataCid, "QmTestAddtlDataCid");
        assertEq(configEndDate, block.timestamp + 1 weeks);
        assertEq(configStartDate, block.timestamp);
    }

    function testApplyAsContributorEmitsEvent() public {
        contributorEligibility.setEligible(true);
        vm.expectEmit(true, false, false, false);
        emit Mission.ApplicationSubmitted(contributor);
        vm.prank(contributor);
        mission.applyAsContributor();
    }

    function testApplyAsContributorReapplyingReverts() public {
        contributorEligibility.setEligible(true);
        vm.prank(contributor);
        mission.applyAsContributor();

        vm.expectRevert(ApplicationAlreadySubmitted.selector);
        vm.prank(contributor);
        mission.applyAsContributor();
    }

    function testApplyAsContributorNotEligible() public {
        contributorEligibility.setEligible(false);
        vm.prank(contributor);
        vm.expectRevert(NotEligible.selector);
        mission.applyAsContributor();
    }

    function testAcceptApplicationSucceed() public {
        contributorEligibility.setEligible(true);
        vm.prank(contributor);
        mission.applyAsContributor();

        vm.prank(sponsor);
        vm.expectEmit(true, true, false, false);
        emit Mission.ApplicationApproved(contributor, sponsor);
        mission.acceptApplication(contributor);
        assertTrue(mission.hasRole(Roles.CONTRIBUTOR_ROLE, contributor));
    }

    function testRejectApplication() public {
        contributorEligibility.setEligible(true);
        vm.prank(contributor);
        mission.applyAsContributor();

        vm.prank(sponsor);
        vm.expectEmit(true, true, false, false);
        emit Mission.ApplicationRejected(contributor, "a very good reason", sponsor);
        mission.rejectApplication(contributor, "a very good reason");
        assertFalse(mission.hasRole(Roles.CONTRIBUTOR_ROLE, contributor));
    }

    function testApplicationNotFoundAccept() public {
        vm.prank(sponsor);
        vm.expectRevert(ApplicationNotFound.selector);
        mission.acceptApplication(contributor);
    }

    function testApplicationNotFoundReject() public {
        vm.prank(sponsor);
        vm.expectRevert(ApplicationNotFound.selector);
        mission.rejectApplication(contributor, "a reason");
    }

    function testVerifierRoleManagement() public {
        assertFalse(mission.hasRole(Roles.VERIFIER_ROLE, verifier));
        // Grant verifier role
        vm.prank(sponsor);
        mission.grantRole(Roles.VERIFIER_ROLE, verifier);
        assertTrue(mission.hasRole(Roles.VERIFIER_ROLE, verifier));

        // Revoke verifier role
        vm.prank(sponsor);
        mission.revokeRole(Roles.VERIFIER_ROLE, verifier);
        assertFalse(mission.hasRole(Roles.VERIFIER_ROLE, verifier));
    }

    function testContributorRoleManagement() public {
        // Apply as contributor
        contributorEligibility.setEligible(true);
        vm.prank(contributor);
        mission.applyAsContributor();

        // Approve application
        vm.prank(sponsor);
        mission.acceptApplication(contributor);
        assertTrue(mission.hasRole(Roles.CONTRIBUTOR_ROLE, contributor));

        // Revoke contributor role
        vm.prank(sponsor);
        mission.removeContributor(contributor);
        assertFalse(mission.hasRole(Roles.CONTRIBUTOR_ROLE, contributor));
    }

    function testReturnUnclaimedFundsBeforeEnd() public {
        vm.prank(sponsor);
        vm.expectRevert(MissionNotEndedYet.selector);
        mission.returnUnclaimedFunds();
    }
}
