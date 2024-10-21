// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {Mission, ApplicationAlreadySubmitted, ApplicationNotFound, ContributorNotEligible, MissionNotEndedYet} from "ethos/missions/Mission.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {DistributionStrategy} from "ethos/DistributionStrategy.sol";
import {FakeERC20} from "../helper/FakeERC20.sol";
import {FakeAuthentication} from "../helper/FakeAuthentication.sol";
import {FakeMissionEligibility} from "../helper/FakeMissionEligibility.sol";
import {MissionConfigHelper} from "../helper/MissionConfig.sol";

contract MissionTest is Test {
    Mission public mission;
    FakeERC20 public token;
    FakeAuthentication public authentication;
    FakeMissionEligibility public contributorEligibility;
    address public sponsor;
    address public manager;
    address public contributor;
    address public verifier;
    address public missionFactoryOwner;

    function setUp() public {
        missionFactoryOwner = address(this); // The test contract deploys the MissionFactory
        sponsor = address(1);
        manager = address(2);
        contributor = address(3);
        verifier = address(4);

        token = new FakeERC20("Test Token", "TEST");
        authentication = new FakeAuthentication();
        contributorEligibility = new FakeMissionEligibility();
        MissionConfig memory config = MissionConfigHelper.createTestConfig(sponsor, address(token));

        // Ensure the sponsor has enough tokens to fund the mission
        token.mint(sponsor, config.bountyAmount);

        mission = new Mission(
            config,
            address(authentication),
            address(contributorEligibility),
            missionFactoryOwner // Pass the MissionFactory owner (this test contract)
        );

        // Approve the mission contract to spend tokens on behalf of the sponsor
        vm.prank(sponsor);
        token.approve(address(mission), config.bountyAmount);

        setupRoles();

        // Set all authentication to true for testing
        authentication.setAuthedManager(manager, true);
        authentication.setAuthedVerifier(verifier, true);
        authentication.setAuthedContributor(contributor, true);
    }

    function setupRoles() public {
        // Deployer grants the SPONSOR_ROLE to the sponsor
        mission.grantRole(mission.SPONSOR_ROLE(), sponsor);
        // Sponsor grants the MANAGER_ROLE to the manager
        vm.prank(sponsor);
        mission.grantRole(mission.MANAGER_ROLE(), manager);
    }

    function testInitialRoles() public {
        assertTrue(mission.hasRole(mission.DEFAULT_ADMIN_ROLE(), missionFactoryOwner));
        assertTrue(mission.hasRole(mission.SPONSOR_ROLE(), missionFactoryOwner));
        assertTrue(mission.hasRole(mission.MANAGER_ROLE(), missionFactoryOwner));
        assertTrue(mission.hasRole(mission.SPONSOR_ROLE(), sponsor));
        assertTrue(mission.hasRole(mission.MANAGER_ROLE(), sponsor));
    }

    function testConstructor() public {
        (
            address configSponsor,
            string memory configDescription,
            uint256 configStartDate,
            uint256 configEndDate,
            address configTokenAddress,
            uint256 configBountyAmount,
            DistributionStrategy configDistributionStrategy
        ) = mission.config();
        assertEq(configSponsor, sponsor);
        assertEq(configTokenAddress, address(token));
        assertTrue(mission.hasRole(mission.DEFAULT_ADMIN_ROLE(), missionFactoryOwner));
        assertEq(address(mission.contributorEligibilityModule()), address(contributorEligibility));
        assertEq(configBountyAmount, 1000);
        assertEq(uint(configDistributionStrategy), uint(DistributionStrategy.Equal));
        assertEq(configDescription, "Test Mission");
        assertEq(configEndDate, block.timestamp + 1 weeks);
        assertEq(configStartDate, block.timestamp);
        assertEq(address(mission.authModule()), address(authentication));
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
        vm.expectRevert(ContributorNotEligible.selector);
        mission.applyAsContributor();
    }

    function testAcceptApplicationSucceed() public {
        contributorEligibility.setEligible(true);
        vm.prank(contributor);
        mission.applyAsContributor();

        vm.prank(manager);
        vm.expectEmit(true, true, false, false);
        emit Mission.ApplicationApproved(contributor, manager);
        mission.acceptApplication(contributor);
        assertTrue(mission.hasRole(mission.CONTRIBUTOR_ROLE(), contributor));
    }

    function testRejectApplication() public {
        contributorEligibility.setEligible(true);
        vm.prank(contributor);
        mission.applyAsContributor();

        vm.prank(manager);
        vm.expectEmit(true, true, false, false);
        emit Mission.ApplicationRejected(contributor, "a very good reason", manager);
        mission.rejectApplication(contributor, "a very good reason");
        assertFalse(mission.hasRole(mission.CONTRIBUTOR_ROLE(), contributor));
    }

    function testApplicationNotFoundAccept() public {
        vm.prank(manager);
        vm.expectRevert(ApplicationNotFound.selector);
        mission.acceptApplication(contributor);
    }

    function testApplicationNotFoundReject() public {
        vm.prank(manager);
        vm.expectRevert(ApplicationNotFound.selector);
        mission.rejectApplication(contributor, "a reason");
    }

    function testManagerRoleManagement() public {
        // Manager role is already set up in the setup function
        // Revoke manager role
        vm.prank(sponsor);
        mission.revokeManagerRole(manager);
        assertFalse(mission.hasRole(mission.MANAGER_ROLE(), manager));
    }

    function testVerifierRoleManagement() public {
        assertFalse(mission.hasRole(mission.VERIFIER_ROLE(), verifier));
        // Grant verifier role
        vm.prank(manager);
        mission.grantVerifierRole(verifier);
        assertTrue(mission.hasRole(mission.VERIFIER_ROLE(), verifier));

        // Revoke verifier role
        vm.prank(manager);
        mission.revokeVerifierRole(verifier);
        assertFalse(mission.hasRole(mission.VERIFIER_ROLE(), verifier));
    }

    function testContributorRoleManagement() public {
        // Apply as contributor
        contributorEligibility.setEligible(true);
        vm.prank(contributor);
        mission.applyAsContributor();

        // Approve application
        vm.prank(manager);
        mission.acceptApplication(contributor);
        assertTrue(mission.hasRole(mission.CONTRIBUTOR_ROLE(), contributor));

        // Revoke contributor role
        vm.prank(manager);
        mission.revokeContributorRole(contributor);
        assertFalse(mission.hasRole(mission.CONTRIBUTOR_ROLE(), contributor));
    }

    function testReturnUnclaimedFundsBeforeEnd() public {
        vm.prank(sponsor);
        vm.expectRevert(MissionNotEndedYet.selector);
        mission.returnUnclaimedFunds();
    }
}
