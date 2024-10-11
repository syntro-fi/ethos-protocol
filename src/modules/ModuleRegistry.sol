// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ModuleRegistry {
    mapping(string => address) public modules;

    error EmptyModuleName();

    function registerModule(string calldata name, address moduleAddress) external {
        if (bytes(name).length == 0) {
            revert EmptyModuleName();
        }
        modules[name] = moduleAddress;
    }

    function getModule(string calldata name) external view returns (address) {
        return modules[name];
    }
}
