// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MulSigWallet {
    /// @notice it's the same code as the second file in this directory
    /// just making sure i get all the concepts right
    /// 5 events Deposit, SubmitTransaction, ConfirmTransaction, RevokeConfirmation, ExecuteTransaction
    /// will be emitted in our functions 
    /// receive(), submitTransaction, confirmTransaction, revokeConfirmation, executeTransaction
    
    /// @notice deposit events takes in the amount deposited, the address of the sender, and his balance
    event Deposit();
}