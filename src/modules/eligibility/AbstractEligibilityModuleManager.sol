// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";

import {Roles} from "ethos/Roles.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {IMissionEligibility} from "ethos/missions/interfaces/IMissionEligibility.sol";

import {IEligibilityModuleManager} from "./interfaces/IEligibilityModuleManager.sol";

abstract contract AbstractEligibilityModuleManager is
    IEligibilityModuleManager,
    IMissionEligibility,
    AccessControl
{
    struct Module {
        address next;
        bool enabled;
    }

    mapping(address => Module) internal _modules;
    address internal immutable _SENTINEL = address(0x1);

    constructor(address _sponsor) {
        _grantRole(Roles.SPONSOR_ROLE, msg.sender);
        _grantRole(Roles.SPONSOR_ROLE, _sponsor);
        _modules[_SENTINEL] = Module(address(0), true);
    }

    function enable(address module) external onlyRole(Roles.SPONSOR_ROLE) {
        _enableModule(module);
        emit ModuleEnabled(module, _getUserType());
    }

    function disable(address module) external onlyRole(Roles.SPONSOR_ROLE) {
        _disableModule(module);
        emit ModuleDisabled(module, _getUserType());
    }

    function getEligibilityModules() external view returns (address[] memory) {
        return _getModules();
    }

    function isEligibilityModuleEnabled(address module) external view returns (bool) {
        return _isModuleEnabled(module);
    }

    function check(address user, MissionConfig calldata config) external view {
        address current = _modules[_SENTINEL].next;
        while (current != address(0)) {
            IMissionEligibility(current).check(user, config);
            current = _modules[current].next;
        }
    }

    function _enableModule(address module) internal {
        if (module == address(0) || module == _SENTINEL) revert InvalidModule();
        if (_modules[module].enabled) revert ModuleAlreadyEnabled();

        _modules[module] = Module(_modules[_SENTINEL].next, true);
        _modules[_SENTINEL].next = module;
    }

    function _disableModule(address module) internal {
        if (module == address(0) || module == _SENTINEL) revert InvalidModule();
        if (!_modules[module].enabled) revert ModuleNotEnabled();

        address prevModule = _SENTINEL;
        address current = _modules[_SENTINEL].next;

        while (current != address(0) && current != module) {
            prevModule = current;
            current = _modules[current].next;
        }

        if (current != module) revert InvalidModule();

        _modules[prevModule].next = _modules[module].next;
        _modules[module].enabled = false;
        _modules[module].next = address(0);
    }

    function _getModules() internal view returns (address[] memory moduleAddresses) {
        uint256 count = 0;
        address current = _modules[_SENTINEL].next;
        while (current != address(0)) {
            count++;
            current = _modules[current].next;
        }

        moduleAddresses = new address[](count);
        current = _modules[_SENTINEL].next;
        for (uint256 i = 0; i < count; i++) {
            moduleAddresses[i] = current;
            current = _modules[current].next;
        }
    }

    function _isModuleEnabled(address module) internal view returns (bool) {
        return module != _SENTINEL && _modules[module].enabled;
    }

    function _getUserType() internal pure virtual returns (UserType);
}
