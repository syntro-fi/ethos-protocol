// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {DistributionStrategy} from "ethos/DistributionStrategy.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {MissionFactory, ModuleRegistryNotProvided, AuthenticationModuleNotFound, EligibilityModuleNotFound, InsufficientFunds} from "ethos/missions/MissionFactory.sol";
import {ModuleRegistry} from "ethos/modules/ModuleRegistry.sol";
import {Modules} from "ethos/modules/Modules.sol";

import {FakeERC20} from "../helper/FakeERC20.sol";

contract MissionFactoryTest is Test {
    MissionFactory public missionFactory;
    ModuleRegistry public moduleRegistry;
    address public owner;
    FakeERC20 public fakeToken;

    function setUp() public {
        owner = address(this);
        moduleRegistry = new ModuleRegistry();
        fakeToken = new FakeERC20("Fake Token", "FTK");

        missionFactory = new MissionFactory(address(moduleRegistry));
    }

    function testConstructor() public {
        assertTrue(missionFactory.hasRole(missionFactory.DEFAULT_ADMIN_ROLE(), address(this)));
        assertEq(address(missionFactory.moduleRegistry()), address(moduleRegistry));
        assertEq(missionFactory.owner(), owner);
    }

    function testConstructorReverts() public {
        vm.expectRevert(ModuleRegistryNotProvided.selector);
        new MissionFactory(address(0));
    }

    function _createFakeMissionConfig() internal view returns (MissionConfig memory) {
        return
            MissionConfig({
                sponsor: address(this),
                description: "Test Mission",
                // solhint-disable-next-line not-rely-on-time
                startDate: block.timestamp,
                // solhint-disable-next-line not-rely-on-time
                endDate: block.timestamp + 7 days,
                tokenAddress: address(fakeToken),
                bountyAmount: 1000 * 10 ** 18,
                distributionStrategy: DistributionStrategy.Equal
            });
    }

    function _setupEligibilityModule() internal returns (address) {
        address fakeContributorEligibilityModule = address(0x456);
        moduleRegistry.register(
            Modules.CONTRIBUTOR_ELIGIBILITY_MODULE,
            fakeContributorEligibilityModule
        );
        return fakeContributorEligibilityModule;
    }

    function _setupAuthModule() internal returns (address) {
        address fakeAuthModule = address(0x789);
        moduleRegistry.register(Modules.AUTHENTICATION_MODULE, fakeAuthModule);
        return fakeAuthModule;
    }

    function _setupAllModules() internal returns (address, address) {
        return (_setupEligibilityModule(), _setupAuthModule());
    }

    function testCreateMission() public {
        MissionConfig memory config = _createFakeMissionConfig();

        _setupAllModules();

        fakeToken.approve(address(missionFactory), config.bountyAmount);
        fakeToken.mint(address(this), config.bountyAmount);
        uint256 balanceBefore = fakeToken.balanceOf(address(this));

        vm.expectEmit(false, false, false, false);
        emit MissionFactory.MissionCreated(address(0)); // We can't predict the exact address, so we use a dummy
        address missionAddress = missionFactory.createMission(config);

        assertTrue(missionAddress != address(0), "Mission address should not be zero");

        uint256 balanceAfter = fakeToken.balanceOf(address(this));
        assertEq(balanceAfter, balanceBefore - config.bountyAmount, "Incorrect amount transferred");

        uint256 missionBalance = fakeToken.balanceOf(missionAddress);
        assertEq(missionBalance, config.bountyAmount, "Mission did not receive correct amount");
    }

    function testCreateMissionRevertsInsufficientFunds() public {
        MissionConfig memory config = _createFakeMissionConfig();
        config.bountyAmount = fakeToken.balanceOf(address(this)) + 1;

        _setupAllModules();

        fakeToken.approve(address(missionFactory), config.bountyAmount);

        vm.expectRevert(InsufficientFunds.selector);
        missionFactory.createMission(config);
    }

    function testCreateMissionRevertsContributorEligibilityModuleNotFound() public {
        _setupAuthModule();

        MissionConfig memory config = _createFakeMissionConfig();

        vm.expectRevert(EligibilityModuleNotFound.selector);
        missionFactory.createMission(config);
    }

    function testCreateMissionRevertsAuthenticationModuleNotFound() public {
        _setupEligibilityModule();

        MissionConfig memory config = _createFakeMissionConfig();

        vm.expectRevert(AuthenticationModuleNotFound.selector);
        missionFactory.createMission(config);
    }
}
