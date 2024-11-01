// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {DistributionStrategy} from "ethos/DistributionStrategy.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {MissionFactory, EligibilityModuleNotFound, InsufficientFunds} from "ethos/missions/MissionFactory.sol";
import {ModuleRegistry} from "ethos/modules/ModuleRegistry.sol";
import {IEligibilityModuleManager} from "ethos/modules/eligibility/interfaces/IEligibilityModuleManager.sol";

import {FakeModule1, FakeModule2} from "../modules/FakeModules.sol";

import {FakeERC20} from "./FakeERC20.sol";

contract MissionFactoryTest is Test {
    MissionFactory public missionFactory;
    ModuleRegistry public moduleRegistry;
    address public owner;
    FakeERC20 public fakeToken;

    function setUp() public {
        owner = address(this);
        moduleRegistry = new ModuleRegistry();
        fakeToken = new FakeERC20("Fake Token", "FTK");

        missionFactory = new MissionFactory();
    }

    function testConstructor() public view {
        assertEq(missionFactory.owner(), owner);
    }

    function _createFakeMissionConfig() internal view returns (MissionConfig memory) {
        return
            MissionConfig({
                sponsor: address(this),
                // solhint-disable-next-line not-rely-on-time
                startDate: block.timestamp,
                // solhint-disable-next-line not-rely-on-time
                endDate: block.timestamp + 7 days,
                tokenAddress: address(fakeToken),
                bountyAmount: 1000 * 10 ** 18,
                distributionStrategy: DistributionStrategy.Equal,
                addtlDataCid: "QmTestAddtlDataCid"
            });
    }

    function _setupContributorEligibilityModule() internal returns (address) {
        FakeModule1 fakeModule = new FakeModule1();
        moduleRegistry.register(
            address(fakeModule),
            "Fake Contributor Eligibility Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );
        return address(fakeModule);
    }

    function _setupVerifierEligibilityModule() internal returns (address) {
        FakeModule2 fakeModule = new FakeModule2();
        moduleRegistry.register(
            address(fakeModule),
            "Fake Verifier Eligibility Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );
        return address(fakeModule);
    }

    function _setupAllModules() internal returns (address, address) {
        address contributorEligibility = _setupContributorEligibilityModule();
        address verifierEligibility = _setupVerifierEligibilityModule();
        return (contributorEligibility, verifierEligibility);
    }

    function testCreateMission() public {
        MissionConfig memory config = _createFakeMissionConfig();

        (address contributorEligibility, address verifierEligibility) = _setupAllModules();

        fakeToken.approve(address(missionFactory), config.bountyAmount);
        fakeToken.mint(address(this), config.bountyAmount);
        uint256 balanceBefore = fakeToken.balanceOf(address(this));

        vm.expectEmit(false, false, false, false);
        emit MissionFactory.MissionCreated(address(0)); // We can't predict the exact address, so we use a dummy
        address missionAddress = missionFactory.createMission(
            config,
            contributorEligibility,
            verifierEligibility
        );

        assertTrue(missionAddress != address(0), "Mission address should not be zero");

        uint256 balanceAfter = fakeToken.balanceOf(address(this));
        assertEq(balanceAfter, balanceBefore - config.bountyAmount, "Incorrect amount transferred");

        uint256 missionBalance = fakeToken.balanceOf(missionAddress);
        assertEq(missionBalance, config.bountyAmount, "Mission did not receive correct amount");
    }

    function testCreateMissionRevertsInsufficientFunds() public {
        MissionConfig memory config = _createFakeMissionConfig();
        config.bountyAmount = fakeToken.balanceOf(address(this)) + 1;

        (address contributorEligibility, address verifierEligibility) = _setupAllModules();

        fakeToken.approve(address(missionFactory), config.bountyAmount);

        vm.expectRevert(InsufficientFunds.selector);
        missionFactory.createMission(config, contributorEligibility, verifierEligibility);
    }

    function testCreateMissionRevertsContributorEligibilityModuleNotFound() public {
        address verifierEligibility = _setupVerifierEligibilityModule();

        MissionConfig memory config = _createFakeMissionConfig();

        vm.expectRevert(
            abi.encodeWithSelector(
                EligibilityModuleNotFound.selector,
                IEligibilityModuleManager.UserType.Contributor
            )
        );
        missionFactory.createMission(config, address(0), verifierEligibility);
    }

    function testCreateMissionRevertsVerifierEligibilityModuleNotFound() public {
        address contributorEligibility = _setupContributorEligibilityModule();

        MissionConfig memory config = _createFakeMissionConfig();

        vm.expectRevert(
            abi.encodeWithSelector(
                EligibilityModuleNotFound.selector,
                IEligibilityModuleManager.UserType.Verifier
            )
        );
        missionFactory.createMission(config, contributorEligibility, address(0));
    }
}
