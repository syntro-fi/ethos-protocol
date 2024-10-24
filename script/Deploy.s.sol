// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "ethos/modules/ModuleRegistry.sol";
import "ethos/modules/eligibility/ContributorEligibilityManager.sol";
import "ethos/modules/eligibility/VerifierEligibilityManager.sol";
import "ethos/modules/eligibility/PassportKYCModule.sol";
import "ethos/modules/eligibility/AlwaysEligibleModule.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contracts
        ModuleRegistry moduleRegistry = new ModuleRegistry();
        ContributorEligibilityManager contributorEligibilityManager = new ContributorEligibilityManager(
                address(moduleRegistry)
            );
        VerifierEligibilityManager verifierEligibilityManager = new VerifierEligibilityManager(
            address(moduleRegistry)
        );
        PassportKYCModule passportKYCModule = new PassportKYCModule();
        AlwaysEligibleModule alwaysEligibleModule = new AlwaysEligibleModule();

        // Register and enable modules
        moduleRegistry.register(
            address(passportKYCModule),
            "Passport KYC Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );
        moduleRegistry.register(
            address(alwaysEligibleModule),
            "Always Eligible Module",
            ModuleRegistry.ModuleCategory.Eligibility
        );
        contributorEligibilityManager.enable(address(alwaysEligibleModule));
        verifierEligibilityManager.enable(address(passportKYCModule));

        vm.stopBroadcast();
    }
}
