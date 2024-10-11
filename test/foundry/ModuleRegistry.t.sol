// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {ModuleRegistry} from "../../src/modules/ModuleRegistry.sol";

contract ModuleRegistryTest is Test {
    ModuleRegistry public registry;
    address public constant MODULE_ADDRESS = address(0x123);
    string public constant MODULE_NAME = "TestModule";

    function setUp() public {
        registry = new ModuleRegistry();
    }

    function testRegisterModule() public {
        registry.registerModule(MODULE_NAME, MODULE_ADDRESS);
        assertEq(registry.getModule(MODULE_NAME), MODULE_ADDRESS, "Module address should match");
    }

    function testGetNonExistentModule() public {
        assertEq(registry.getModule("NonExistentModule"), address(0), "Non-existent module should return zero address");
    }

    function testRegisterMultipleModules() public {
        string memory moduleName2 = "AnotherModule";
        address moduleAddress2 = address(0x456);

        registry.registerModule(MODULE_NAME, MODULE_ADDRESS);
        registry.registerModule(moduleName2, moduleAddress2);

        assertEq(registry.getModule(MODULE_NAME), MODULE_ADDRESS, "First module address should match");
        assertEq(registry.getModule(moduleName2), moduleAddress2, "Second module address should match");
    }

    function testOverwriteExistingModule() public {
        address newModuleAddress = address(0x789);

        registry.registerModule(MODULE_NAME, MODULE_ADDRESS);
        registry.registerModule(MODULE_NAME, newModuleAddress);

        assertEq(registry.getModule(MODULE_NAME), newModuleAddress, "Module address should be overwritten");
    }

    function testRegisterModuleEmptyName() public {
        vm.expectRevert(abi.encodeWithSignature("EmptyModuleName()"));
        registry.registerModule("", MODULE_ADDRESS);
    }

    function testRegisterModuleZeroAddress() public {
        registry.registerModule(MODULE_NAME, address(0));
        assertEq(registry.getModule(MODULE_NAME), address(0), "Zero address module should be registered");
    }

    function testModulesMapping() public {
        registry.registerModule(MODULE_NAME, MODULE_ADDRESS);
        assertEq(registry.modules(MODULE_NAME), MODULE_ADDRESS, "modules mapping should be accessible and correct");
    }
}
