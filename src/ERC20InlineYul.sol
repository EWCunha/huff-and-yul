// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ERC20InlineYul {
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
        assembly {
            let nameLength := mload(name_)
            let nameData := mload(add(name_, 0x20))
            switch lt(nameLength, 0x20)
            case 0x01 {
                sstore(name.slot, or(nameData, mul(nameLength, 0x02)))
            }
            case 0x00 {
                sstore(name.slot, add(mul(nameLength, 0x02), 0x01))
                mstore(0x00, name.slot)
                let baseLoc := keccak256(0x00, 0x20)
                // Store the string content by blocks of 32 bytes
                for {
                    let i := 0
                } lt(mul(i, 0x20), nameLength) {
                    i := add(i, 0x01)
                } {
                    sstore(
                        add(baseLoc, i),
                        mload(add(name_, mul(add(i, 1), 0x20)))
                    )
                }
            }

            let symbolLength := mload(symbol_)
            let symbolData := mload(add(symbol_, 0x20))
            switch lt(symbolLength, 0x20)
            case 0x01 {
                sstore(symbol.slot, or(symbolData, mul(symbolLength, 0x02)))
            }
            case 0x00 {
                sstore(symbol.slot, add(mul(symbolLength, 0x02), 0x01))
                mstore(0x00, symbol.slot)
                let baseLoc := keccak256(0x00, 0x20)
                // Store the string content by blocks of 32 bytes
                for {
                    let i := 0
                } lt(mul(i, 0x20), symbolLength) {
                    i := add(i, 0x01)
                } {
                    sstore(
                        add(baseLoc, i),
                        mload(add(symbol_, mul(add(i, 1), 0x20)))
                    )
                }
            }

            sstore(decimals.slot, decimals_)
            sstore(totalSupply.slot, totalSupply_)

            let freeMemPointer := mload(0x40)
            mstore(freeMemPointer, caller())
            mstore(add(freeMemPointer, 0x20), balanceOf.slot)
            sstore(keccak256(freeMemPointer, 0x40), totalSupply_)
        }
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        assembly {
            let freeMemPointer := mload(0x40)
            mstore(freeMemPointer, caller())
            mstore(add(freeMemPointer, 0x20), balanceOf.slot)
            let senderBalance := sload(keccak256(freeMemPointer, 0x40))
            if lt(senderBalance, amount) {
                mstore(freeMemPointer, shl(0xe0, 0x08c379a0)) // Error signature for "Error(string)"
                mstore(add(freeMemPointer, 0x04), 0x20) // Offset to the string data
                mstore(add(freeMemPointer, 0x24), 0x12) // String length (18 bytes)
                mstore(add(freeMemPointer, 0x44), "not enough balance") // Error message
                revert(freeMemPointer, 0x64) // Revert with (offset, length)
            }

            sstore(keccak256(freeMemPointer, 0x40), sub(senderBalance, amount))
            mstore(freeMemPointer, to)
            mstore(add(freeMemPointer, 0x20), balanceOf.slot)
            let toAmount := sload(keccak256(freeMemPointer, 0x40))
            sstore(keccak256(freeMemPointer, 0x40), add(toAmount, amount))

            mstore(freeMemPointer, amount)
            log3(
                freeMemPointer,
                0x20,
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                caller(),
                to
            )

            mstore(freeMemPointer, true)
            return(freeMemPointer, 0x20)
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        assembly {
            let freeMemPointer := mload(0x40)
            mstore(freeMemPointer, from)
            mstore(add(freeMemPointer, 0x20), balanceOf.slot)
            let senderBalance := sload(keccak256(freeMemPointer, 0x40))
            if lt(senderBalance, amount) {
                mstore(freeMemPointer, shl(0xe0, 0x08c379a0)) // Error signature for "Error(string)"
                mstore(add(freeMemPointer, 0x04), 0x20) // Offset to the string data
                mstore(add(freeMemPointer, 0x24), 0x12) // String length (18 bytes)
                mstore(add(freeMemPointer, 0x44), "not enough balance") // Error message
                revert(freeMemPointer, 0x64) // Revert with (offset, length)
            }

            if iszero(eq(caller(), from)) {
                mstore(add(freeMemPointer, 0x20), allowance.slot)
                mstore(add(freeMemPointer, 0x40), caller())
                mstore(
                    add(freeMemPointer, 0x60),
                    keccak256(freeMemPointer, 0x40)
                )
                let callerAllowance := sload(
                    keccak256(add(freeMemPointer, 0x40), 0x40)
                )

                if lt(callerAllowance, amount) {
                    mstore(freeMemPointer, shl(0xe0, 0x08c379a0)) // Error signature for "Error(string)"
                    mstore(add(freeMemPointer, 0x04), 0x20) // Offset to the string data
                    mstore(add(freeMemPointer, 0x24), 0x14) // String length (20 bytes)
                    mstore(add(freeMemPointer, 0x44), "not enough allowance") // Error message
                    revert(freeMemPointer, 0x64) // Revert with (offset, length)
                }

                sstore(
                    keccak256(add(freeMemPointer, 0x40), 0x40),
                    sub(callerAllowance, amount)
                )
            }

            sstore(keccak256(freeMemPointer, 0x40), sub(senderBalance, amount))
            mstore(freeMemPointer, to)
            mstore(add(freeMemPointer, 0x20), balanceOf.slot)
            let toAmount := sload(keccak256(freeMemPointer, 0x40))
            sstore(keccak256(freeMemPointer, 0x40), add(toAmount, amount))

            mstore(freeMemPointer, amount)
            log3(
                freeMemPointer,
                0x20,
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                from,
                to
            )

            mstore(freeMemPointer, true)
            return(freeMemPointer, 0x20)
        }
    }

    function approve(address spender, uint256 value) external returns (bool) {
        assembly {
            let freeMemPointer := mload(0x40)
            mstore(freeMemPointer, caller())
            mstore(add(freeMemPointer, 0x20), allowance.slot)
            mstore(add(freeMemPointer, 0x40), spender)
            mstore(add(freeMemPointer, 0x60), keccak256(freeMemPointer, 0x40))
            sstore(keccak256(add(freeMemPointer, 0x40), 0x40), value)

            mstore(freeMemPointer, value)
            log3(
                freeMemPointer,
                0x20,
                0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925,
                caller(),
                spender
            )

            mstore(freeMemPointer, true)
            return(freeMemPointer, 0x20)
        }
    }
}
