// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";

import {ModuleRegistry} from "ethos/modules/ModuleRegistry.sol";
import {IModule} from "ethos/modules/interfaces/IModule.sol";
import {FakeModule1, FakeModule2} from "./FakeModules.sol";

contract ModuleRegistryTest is Test {
    ModuleRegistry public registry;
    address public owner;
    FakeModule1 public fakeModule;
    FakeModule2 public fakeModule2;

    function setUp() public {
        owner = address(this);
        registry = new ModuleRegistry();
        fakeModule = new FakeModule1();
        fakeModule2 = new FakeModule2();
    }

    function testRegister() public {
        registry.register(
            address(fakeModule),
            "Fake Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );

        ModuleRegistry.ModuleInfo[] memory modules = registry.getAll();
        assertEq(modules.length, 1);
        assertEq(modules[0].addr, address(fakeModule));
        assertEq(modules[0].name, "Fake Module");
        assertEq(uint(modules[0].category), uint(ModuleRegistry.ModuleCategory.Eligibility));
    }

    function testRegisterRevertIfAlreadyRegistered() public {
        registry.register(
            address(fakeModule),
            "Fake Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );

        vm.expectRevert(ModuleRegistry.ModuleAlreadyRegistered.selector);
        registry.register(
            address(fakeModule),
            "Fake Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );
    }

    function testRegisterRevertIfInvalidModule() public {
        vm.expectRevert(ModuleRegistry.InvalidModule.selector);
        registry.register(address(0), "Invalid Module", ModuleRegistry.ModuleCategory.Eligibility);
    }

    function testRemove() public {
        registry.register(
            address(fakeModule),
            "Fake Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );
        registry.remove(address(fakeModule));

        assertEq(registry.getAll().length, 0);
    }

    function testRemoveRevertIfNotRegistered() public {
        vm.expectRevert(ModuleRegistry.ModuleNotRegistered.selector);
        registry.remove(address(fakeModule));
    }

    function testRemoveRevertIfInvalidModule() public {
        vm.expectRevert(ModuleRegistry.InvalidModule.selector);
        registry.remove(address(0));
    }

    function testGet() public {
        registry.register(
            address(fakeModule),
            "Fake Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );

        assertEq(registry.get(fakeModule.moduleId()), address(fakeModule));
    }

    function testGetAll() public {
        registry.register(
            address(fakeModule),
            "Fake Module 1",
            ModuleRegistry.ModuleCategory.Eligibility
        );
        registry.register(
            address(fakeModule2),
            "Fake Module 2",
            ModuleRegistry.ModuleCategory.Eligibility
        );

        ModuleRegistry.ModuleInfo[] memory modules = registry.getAll();
        assertEq(modules.length, 2);
        assertEq(modules[0].addr, address(fakeModule));
        assertEq(modules[0].name, "Fake Module 1");
        assertEq(uint(modules[0].category), uint(ModuleRegistry.ModuleCategory.Eligibility));
        assertEq(modules[1].addr, address(fakeModule2));
        assertEq(modules[1].name, "Fake Module 2");
        assertEq(uint(modules[1].category), uint(ModuleRegistry.ModuleCategory.Eligibility));
    }

    function testOnlyAdminCanRegister() public {
        address nonAdmin = address(0x1);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                nonAdmin,
                registry.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(nonAdmin);
        registry.register(
            address(fakeModule),
            "Fake Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );
    }

    function testOnlyAdminCanRemove() public {
        registry.register(
            address(fakeModule),
            "Fake Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );

        address nonAdmin = address(0x1);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                nonAdmin,
                registry.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(nonAdmin);
        registry.remove(address(fakeModule));
    }
}
