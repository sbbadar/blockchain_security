// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniEthBank {
    // uint8 limits "Eth" to 255 for easy classroom tracking
    uint8 public walletBalance = 0; 

    // 1. UNDERFLOW: Subtracting from 0 makes it 255 (Maximum)
    function exploitWithdraw(uint8 _amount) public {
        // In 0.8.0, we MUST use 'unchecked' to force this "glitch"
        unchecked { 
            walletBalance -= _amount; 
        }
    }

    // 2. OVERFLOW: Adding to 255 makes it 0 (Minimum)
    function exploitDeposit(uint8 _amount) public {
        // If balance is 255 and we add 1, it suddenly becomes 0
        unchecked { 
            walletBalance += _amount; 
        }
    }

    // 3. SECURE METHOD: Reverts automatically if math is invalid
    // function secureTransaction(uint8 _amount, bool isDeposit) public {
    //     if(isDeposit) {
    //         walletBalance += _amount; // Reverts if > 255
    //     } else {
    //         walletBalance -= _amount; // Reverts if > current balance
    //     }
    }
// }