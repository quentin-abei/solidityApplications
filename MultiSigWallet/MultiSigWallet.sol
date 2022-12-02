// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MultiSigWallet {
    /// @notice wallet owner can submit a transaction
    /// approve and revoke approval of pending transactions
    /// anyone can execute a transaction after enough owners has
    /// approved it

    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    struct Transaction {
        /// @notice numConfirmations to track minimum number of confirmation required before executing a transaction
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }
    
    /// @notice for each txIndex look if owner has confirmed it
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    /// @notice modifier to check if sender is the owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    /// @notice modifier to check if tx exists
    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "Tx does not exist");
        _;
    }

    /// @notice modifier to check if tx is not executed 
    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    /// @notice modifier to check that tx is not confirmed
    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "Already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        
    }
}