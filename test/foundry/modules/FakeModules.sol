// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IModule} from "ethos/modules/interfaces/IModule.sol";

contract FakeModule1 is IModule {
    function moduleId() external pure override returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked("FakeModule1")));
    }
}

contract FakeModule2 is IModule {
    function moduleId() external pure override returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked("FakeModule2")));
    }
}

contract FakeModule3 is IModule {
    function moduleId() external pure override returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked("FakeModule3")));
    }
}
