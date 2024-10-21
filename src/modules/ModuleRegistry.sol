// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ModuleRegistry {
error EmptyModuleName();

    mapping(string => address) public modules;


    function register(
        string calldata name,
        address moduleAddress
    ) external {
        if (bytes(name).length == 0) {
            revert EmptyModuleName();
        }
        modules[name] = moduleAddress;
    }

    function get(string calldata name) external view returns (address) {
        return modules[name];
    }
}
