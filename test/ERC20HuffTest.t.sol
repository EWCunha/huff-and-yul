// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {BaseTest, IERC20} from "./BaseTest.t.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract ERC20HuffTest is BaseTest {
    string public constant ERC20_HUFF_LOCATION = "ERC20";

    function setUp() public override {
        bytes memory args = abi.encode(name, symbol, decimals, totalSupply);
        erc20 = IERC20(
            HuffDeployer
                .config()
                .with_args(args)
                .with_deployer(deployer)
                .deploy(ERC20_HUFF_LOCATION)
        );
    }

    // function testConstructor() public view override {
    //     // erc20.name();
    //     // bytes memory encoded = abi.encodeWithSignature("name()");
    //     console.logBytes(abi.encode(name, symbol, decimals, totalSupply));
    // }
}
