// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {ModuleRegistry} from "ethos/modules/ModuleRegistry.sol";

contract ModuleRegistryTest is Test {
    ModuleRegistry public registry;
    address public constant MODULE_ADDRESS = address(0x123);
    string public constant MODULE_NAME = "TestModule";

    function setUp() public {
        registry = new ModuleRegistry();
    }

    function testRegisterModule() public {
        registry.register(MODULE_NAME, MODULE_ADDRESS);
        assertEq(registry.get(MODULE_NAME), MODULE_ADDRESS, "Module address should match");
    }

    function testGetNonExistentModule() public {
        assertEq(
            registry.get("NonExistentModule"),
            address(0),
            "Non-existent module should return zero address"
        );
    }

    function testRegisterMultipleModules() public {
        string memory moduleName2 = "AnotherModule";
        address moduleAddress2 = address(0x456);

        registry.register(MODULE_NAME, MODULE_ADDRESS);
        registry.register(moduleName2, moduleAddress2);

        assertEq(registry.get(MODULE_NAME), MODULE_ADDRESS, "First module address should match");
        assertEq(registry.get(moduleName2), moduleAddress2, "Second module address should match");
    }

    function testOverwriteExistingModule() public {
        address newModuleAddress = address(0x789);

        registry.register(MODULE_NAME, MODULE_ADDRESS);
        registry.register(MODULE_NAME, newModuleAddress);

        assertEq(
            registry.get(MODULE_NAME),
            newModuleAddress,
            "Module address should be overwritten"
        );
    }

    function testRegisterModuleEmptyName() public {
        vm.expectRevert(ModuleRegistry.EmptyModuleName.selector);
        registry.register("", MODULE_ADDRESS);
    }

    function testRegisterModuleZeroAddress() public {
        registry.register(MODULE_NAME, address(0));
        assertEq(registry.get(MODULE_NAME), address(0), "Zero address module should be registered");
    }

    function testModulesMapping() public {
        registry.register(MODULE_NAME, MODULE_ADDRESS);
        assertEq(
            registry.get(MODULE_NAME),
            MODULE_ADDRESS,
            "modules mapping should be accessible and correct"
        );
    }
}
