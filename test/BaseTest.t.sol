// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "../src/ERC20.sol";

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}

contract BaseTest is Test {
    IERC20 public erc20;

    string public name = "namenamenamenamenamenamenamenamenamename";
    string public symbol = "symbol";
    uint256 public decimals = 18;
    uint256 public totalSupply = 1000;

    address public deployer = makeAddr("deployer");

    // uint256 public key;

    function setUp() public virtual {
        vm.broadcast(deployer);
        erc20 = IERC20(address(new ERC20(name, symbol, decimals, totalSupply)));
    }

    // function makeDeployer() public {
    //     (address dep, uint256 depKey) = makeAddrAndKey("deployer");
    //     deployer = dep;
    //     key = depKey;
    // }

    function testConstructor() public view virtual {
        assertEq(erc20.name(), name);
        assertEq(erc20.symbol(), symbol);
        assertEq(erc20.decimals(), decimals);
        assertEq(erc20.totalSupply(), totalSupply);
        assertEq(erc20.balanceOf(deployer), totalSupply);
    }

    function testTransferSuccess() public {
        address recipient = makeAddr("recipient");
        uint256 amount = 100;

        uint256 balanceBeforeDeployer = erc20.balanceOf(deployer);
        uint256 balanceBeforeRecipient = erc20.balanceOf(recipient);

        vm.prank(deployer);
        bool result = erc20.transfer(recipient, amount);

        uint256 balanceAfterDeployer = erc20.balanceOf(deployer);
        uint256 balanceAfterRecipient = erc20.balanceOf(recipient);

        assertEq(balanceBeforeDeployer, totalSupply);
        assertEq(balanceBeforeRecipient, 0);
        assertEq(balanceAfterDeployer, totalSupply - amount);
        assertEq(balanceAfterRecipient, amount);
        assertTrue(result);
    }

    function testTransferEvent() public {
        address recipient = makeAddr("recipient");
        uint256 amount = 100;

        vm.prank(deployer);
        vm.expectEmit(true, true, false, true, address(erc20));
        emit IERC20.Transfer(deployer, recipient, amount);
        erc20.transfer(recipient, amount);
    }

    function testTransferFail() public {
        address recipient = makeAddr("recipient");
        uint256 amount = 100;

        vm.prank(recipient);
        vm.expectRevert("not enough balance");
        erc20.transfer(deployer, amount);
    }

    function testTransferFromSuccess() public {
        address recipient = makeAddr("recipient");
        uint256 amount = 100;

        uint256 balanceBeforeDeployer = erc20.balanceOf(deployer);
        uint256 balanceBeforeRecipient = erc20.balanceOf(recipient);

        vm.prank(deployer);
        bool result = erc20.transferFrom(deployer, recipient, amount);

        uint256 balanceAfterDeployer = erc20.balanceOf(deployer);
        uint256 balanceAfterRecipient = erc20.balanceOf(recipient);

        assertEq(balanceBeforeDeployer, totalSupply);
        assertEq(balanceBeforeRecipient, 0);
        assertEq(balanceAfterDeployer, totalSupply - amount);
        assertEq(balanceAfterRecipient, amount);
        assertTrue(result);
    }

    function testTransferFromEvent() public {
        address recipient = makeAddr("recipient");
        uint256 amount = 100;

        vm.prank(deployer);
        vm.expectEmit(true, true, false, true, address(erc20));
        emit IERC20.Transfer(deployer, recipient, amount);
        erc20.transferFrom(deployer, recipient, amount);
    }

    function testTransferFromFail1() public {
        address recipient = makeAddr("recipient");
        uint256 amount = 100;

        vm.prank(recipient);
        vm.expectRevert("not enough balance");
        erc20.transferFrom(recipient, deployer, amount);
    }

    function testTransferFromFail2() public {
        address recipient = makeAddr("recipient");
        uint256 amount = 100;

        vm.prank(recipient);
        vm.expectRevert("not enough allowance");
        erc20.transferFrom(deployer, recipient, amount);
    }

    function testApprove() public {
        address spender = makeAddr("spender");
        uint256 value = 1 ether;

        uint256 allowanceBefore = erc20.allowance(deployer, spender);

        vm.prank(deployer);
        bool result = erc20.approve(spender, value);

        uint256 allowanceAfter = erc20.allowance(deployer, spender);

        assertEq(allowanceBefore, 0);
        assertEq(allowanceAfter, value);
        assertTrue(result);
    }

    function testApproveEvent() public {
        address spender = makeAddr("spender");
        uint256 value = 1 ether;

        vm.prank(deployer);
        vm.expectEmit(true, true, false, true, address(erc20));
        emit IERC20.Approval(deployer, spender, value);
        erc20.approve(spender, value);
    }
}
