// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";

import "ethos/modules/ModuleRegistry.sol";
import "ethos/modules/eligibility/ContributorEligibilityManager.sol";
import "ethos/modules/eligibility/VerifierEligibilityManager.sol";
import "ethos/modules/eligibility/PassportKYCModule.sol";
import "ethos/modules/eligibility/AlwaysEligibleModule.sol";
import "ethos/missions/MissionFactory.sol";

contract FUSDC is ERC20 {
    constructor() ERC20("Fake USDC", "FUSDC") {
        _mint(msg.sender, 1000000 * 10 ** 18); // Mint 1M tokens to deployer
    }
}

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy FUSDC
        FUSDC fusdc = new FUSDC();

        // Deploy core contracts
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

        // Deploy factory with FUSDC as allowed token
        new MissionFactory(address(fusdc));

        // Transfer FUSDC to anvil account
        address recipient = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);
        fusdc.transfer(recipient, 100000 * 10 ** 18);

        vm.stopBroadcast();
    }
}
