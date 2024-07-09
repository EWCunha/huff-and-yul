// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseTest, IERC20} from "./BaseTest.t.sol";
import {ERC20InlineYul} from "../src/ERC20InlineYul.sol";

contract ERC20InlineYulTest is BaseTest {
    function setUp() public override {
        vm.prank(deployer);
        erc20 = IERC20(
            address(new ERC20InlineYul(name, symbol, decimals, totalSupply))
        );
    }
}
