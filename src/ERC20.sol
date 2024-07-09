// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ERC20 {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    mapping(address owner => uint256 balance) public balanceOf;
    mapping(address owner => mapping(address spender => uint256 remaining))
        public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_
    ) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        totalSupply = totalSupply_;
        balanceOf[msg.sender] = totalSupply_;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "not enough balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(balanceOf[from] >= amount, "not enough balance");
        if (msg.sender != from) {
            require(
                allowance[from][msg.sender] >= amount,
                "not enough allowance"
            );
            allowance[from][msg.sender] -= amount;
        }
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);

        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }
}
