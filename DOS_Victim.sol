// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public currentLeader; // Current bidder
    uint256 public highestBid; // The highest bid

    function bid() public payable {
        require(msg.value > highestBid); // The transaction
        require(currentLeader.send(highestBid)); // Return
        currentLeader = payable(msg.sender); // Set the new bidder t
        highestBid = msg.value; // Set the new highest bidd
    }
}


// pragma solidity ^0.8.0;

// contract Auction {
//     address payable public currentLeader; // Mark currentLeader as payable
//     uint256 public highestBid; // The highest bid

//     function bid() public payable {
//         require(msg.value > highestBid, "Bid must be higher than current highest bid"); // The transaction
//         require(currentLeader.send(highestBid), "Failed to refund previous leader"); // Return the highest bid

//         currentLeader = payable(msg.sender); // Set the new bidder as payable
//         highestBid = msg.value; // Set the new highest bid
//     }
// }