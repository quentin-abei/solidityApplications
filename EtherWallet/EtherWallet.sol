// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract EtherWallet {
    // Basic ether wallet
    //anyone can send ether
    //only the owner can withdraw
    //since this address will receive eth
    // let's make it payable
    address public payable owner;
    
    constructor() {
        //upon deployement set the dployer as owner
        // make the address payable
        owner = payable(msg.sender);
    }

    // this will allow the wallet to receive eth
    receive() external payable {}

    function withdraw(uint _amount) external {
        //only the owner can withdraw
        require(msg.sender == owner, "You cannot withdraw");
        //transfer input amount to the owner address
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }

}