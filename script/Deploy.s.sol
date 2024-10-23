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

        // Module registry
        ModuleRegistry moduleRegistry = new ModuleRegistry();
        // Contributor eligibility manager
        ContributorEligibilityManager contributorEligibilityManager = new ContributorEligibilityManager(
                address(moduleRegistry)
            );
        // Verifier eligibility manager
        VerifierEligibilityManager verifierEligibilityManager = new VerifierEligibilityManager(
            address(moduleRegistry)
        );
        // Passport KYC module
        PassportKYCModule passportKYCModule = new PassportKYCModule();
        // Always eligible module
        AlwaysEligibleModule alwaysEligibleModule = new AlwaysEligibleModule();

        moduleRegistry.register(address(passportKYCModule), "Passport KYC Module");
        moduleRegistry.register(address(alwaysEligibleModule), "Always Eligible Module");
        contributorEligibilityManager.enable(address(alwaysEligibleModule));
        verifierEligibilityManager.enable(address(passportKYCModule));

        vm.stopBroadcast();
    }
}
