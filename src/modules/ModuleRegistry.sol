// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";

import {IModule} from "./interfaces/IModule.sol";

/// @title ModuleRegistry
/// @notice A registry for managing different types of modules
contract ModuleRegistry is AccessControl {
    // Errors
    error ModuleAlreadyRegistered();
    error ModuleNotRegistered();
    error InvalidModule();

    // Enums
    enum ModuleCategory {
        Eligibility
    }

    // Structs
    struct ModuleInfo {
        address addr;
        string name;
        ModuleCategory category;
    }

    // State variables
    mapping(bytes4 => ModuleInfo) private _modules;
    bytes4[] private _moduleIds;

    // Events
    event ModuleRegistered(
        bytes4 indexed id,
        address indexed module,
        string name,
        ModuleCategory indexed category
    );
    event ModuleRemoved(bytes4 indexed id, address indexed module);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Register a new module
    /// @param module Address of the module to register
    /// @param name Name of the module
    /// @param category Category of the module
    function register(
        address module,
        string memory name,
        ModuleCategory category
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (module == address(0)) revert InvalidModule();

        bytes4 id = IModule(module).moduleId();
        if (_modules[id].addr != address(0)) revert ModuleAlreadyRegistered();

        _modules[id] = ModuleInfo(module, name, category);
        _moduleIds.push(id);

        emit ModuleRegistered(id, module, name, category);
    }

    /// @notice Remove a module from the registry
    /// @param module Address of the module to remove
    function remove(address module) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (module == address(0)) revert InvalidModule();

        bytes4 id = IModule(module).moduleId();
        if (_modules[id].addr == address(0)) revert ModuleNotRegistered();

        delete _modules[id];

        for (uint128 i = 0; i < _moduleIds.length; i++) {
            if (_moduleIds[i] == id) {
                _moduleIds[i] = _moduleIds[_moduleIds.length - 1];
                _moduleIds.pop();
                break;
            }
        }

        emit ModuleRemoved(id, module);
    }

    /// @notice Get a module by its ID
    /// @param id The module ID to look up
    /// @return The address of the module
    function get(bytes4 id) external view returns (address) {
        return _modules[id].addr;
    }

    /// @notice Get all registered modules
    /// @return An array of ModuleInfo structs containing address, name, and category of all modules
    function getAll() external view returns (ModuleInfo[] memory) {
        ModuleInfo[] memory allModules = new ModuleInfo[](_moduleIds.length);

        for (uint128 i = 0; i < _moduleIds.length; i++) {
            allModules[i] = _modules[_moduleIds[i]];
        }

        return allModules;
    }
}
