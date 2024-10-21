// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";

error EmptyModuleName();

contract ModuleRegistry is AccessControl {
    bytes32 public constant MODULE_MANAGER_ROLE = keccak256("MODULE_MANAGER_ROLE");

    mapping(string => address) public modules;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MODULE_MANAGER_ROLE, msg.sender);
    }

    function register(
        string calldata name,
        address moduleAddress
    ) external onlyRole(MODULE_MANAGER_ROLE) {
        if (bytes(name).length == 0) {
            revert EmptyModuleName();
        }
        modules[name] = moduleAddress;
    }

    function get(string calldata name) external view returns (address) {
        return modules[name];
    }
}
