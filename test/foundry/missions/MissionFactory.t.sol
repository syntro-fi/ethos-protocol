// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {DistributionStrategy} from "ethos/DistributionStrategy.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {MissionFactory, ModuleRegistryNotProvided, AuthenticationModuleNotFound, EligibilityModuleNotFound} from "ethos/missions/MissionFactory.sol";
import {ModuleRegistry} from "ethos/modules/ModuleRegistry.sol";
import {Modules} from "ethos/modules/Modules.sol";

contract MissionFactoryTest is Test {
    MissionFactory public missionFactory;
    ModuleRegistry public moduleRegistry;
    address public owner;

    function setUp() public {
        owner = address(this);
        moduleRegistry = new ModuleRegistry();

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
                tokenAddress: address(0xabc),
                bountyAmount: 1000,
                distributionStrategy: DistributionStrategy.Equal
            });
    }

    function testCreateMission() public {
        MissionConfig memory config = _createFakeMissionConfig();

        address fakeContributorEligibilityModule = address(0x456);
        moduleRegistry.register(
            Modules.CONTRIBUTOR_ELIGIBILITY_MODULE,
            fakeContributorEligibilityModule
        );

        address fakeAuthModule = address(0x789);
        moduleRegistry.register(Modules.AUTHENTICATION_MODULE, fakeAuthModule);


        vm.expectEmit(false, false, false, false);
        emit MissionFactory.MissionCreated(address(0));

        missionFactory.createMission(config);
    }

    function testCreateMissionRevertsContributorEligibilityModuleNotFound() public {
        address fakeAuthModule = address(0x789);
        moduleRegistry.register(Modules.AUTHENTICATION_MODULE, fakeAuthModule);

        MissionConfig memory config = _createFakeMissionConfig();

        vm.expectRevert(EligibilityModuleNotFound.selector);
        missionFactory.createMission(config);
    }

    function testCreateMissionRevertsAuthenticationModuleNotFound() public {
        // Fake only the eligibility module
        address fakeContributorEligibilityModule = address(0x456);
        moduleRegistry.register(
            Modules.CONTRIBUTOR_ELIGIBILITY_MODULE,
            fakeContributorEligibilityModule
        );

        MissionConfig memory config = _createFakeMissionConfig();

        vm.expectRevert(AuthenticationModuleNotFound.selector);
        missionFactory.createMission(config);
    }
}
