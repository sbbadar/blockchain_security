// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// contract VulnerableContract {
//     mapping (address => uint256) public balance;

//     function updateBalance(address _sender, uint256 amount) public {
//         balance[_sender] = amount;
//     }
    
// }



// pragma solidity ^0.8.0;

// contract VulnerableContract {
//     mapping (address => uint256) public balance;

//     function depositt() public payable {
//         balance[msg.sender] += msg.value;
//     }

//     function getContractBalance()public view returns(uint256){
//         return address(this).balance;
//     }
    
// }



pragma solidity ^0.8.0;

contract VulnerableContract {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: bal}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
    }
}
