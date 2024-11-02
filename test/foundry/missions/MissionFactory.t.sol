// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";

import {DistributionStrategy} from "ethos/DistributionStrategy.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {MissionFactory, EligibilityModuleNotFound, InvalidTokenAddress} from "ethos/missions/MissionFactory.sol";
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

        missionFactory = new MissionFactory(address(fakeToken));
    }

    function testConstructor() public view {
        assertEq(missionFactory.owner(), owner);
        assertEq(missionFactory.allowedToken(), address(fakeToken));
    }

    function testSetAllowedToken() public {
        address newToken = address(new FakeERC20("New Token", "NTK"));

        vm.expectEmit(true, false, false, false);
        emit MissionFactory.AllowedTokenUpdated(newToken);
        missionFactory.setAllowedToken(newToken);

        assertEq(missionFactory.allowedToken(), newToken);
    }

    function testSetAllowedTokenRevertsForZeroAddress() public {
        // Grant admin role first
        missionFactory.grantRole(missionFactory.DEFAULT_ADMIN_ROLE(), address(this));

        vm.expectRevert(abi.encodeWithSelector(InvalidTokenAddress.selector));
        missionFactory.setAllowedToken(address(0));
    }

    function testSetAllowedTokenRevertsForNonAdmin() public {
        vm.startPrank(address(1));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(1),
                missionFactory.DEFAULT_ADMIN_ROLE()
            )
        );
        missionFactory.setAllowedToken(address(1));
        vm.stopPrank();
    }

    function _createFakeMissionConfig() internal view returns (MissionConfig memory) {
        return
            MissionConfig({
                sponsor: address(this),
                // solhint-disable-next-line not-rely-on-time
                startDate: block.timestamp,
                // solhint-disable-next-line not-rely-on-time
                endDate: block.timestamp + 7 days,
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

        vm.expectEmit(false, false, false, false);
        emit MissionFactory.MissionCreated(address(0)); // We can't predict the exact address, so we use a dummy
        address missionAddress = missionFactory.createMission(
            config,
            contributorEligibility,
            verifierEligibility
        );

        assertTrue(missionAddress != address(0), "Mission address should not be zero");
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
