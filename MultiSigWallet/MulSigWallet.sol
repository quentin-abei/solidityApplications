// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MulSigWallet {
    /// @notice it's the same code as the second file in this directory
    /// just making sure i get all the concepts right
    /// 5 events Deposit, SubmitTransaction, ConfirmTransaction, RevokeConfirmation, ExecuteTransaction
    /// will be emitted in our functions 
    /// receive(), submitTransaction, confirmTransaction, revokeConfirmation, executeTransaction
    
    /// @notice deposit events takes in the amount deposited, the address of the sender, and his balance
    event Deposit(address indexed sender, uint amount, uint balance);
    /// @notice submit transaction takes in the value , data, the recipient, the owner and the tx index
    event SubmitTransaction (
        address indexed sender,
        address indexed to,
        uint indexed txIndex,
        bytes data,
        uint value
    );
    /// @notice ConfirmTransaction takes in the txindex, the owner
    event ConfirmTransaction (
        address indexed owner, uint indexed txIndex
    );
    /// @notice same for RevokeConfirmation and ExecusteTransaction
    event RevokeConfirmation(
        address indexed owner, uint indexed txIndex
    );
    event ExecuteTransaction(
        address indexed owner, uint indexed txIndex
    );

    /// @notice array to store list of owners addresses
    address[] public owners;
    /// @notice mapping through addresses to check if it's among owners
    mapping(address => bool) public isOwner;
    /// @dev set minimal numbers of confirmations to prevent mallory exploit
    uint public numConfirmationsRequired;

    /// @notice transaction will contains lot of details
    /// so let's make a struct of transaction
    /// struct contain the recipient address, value , data, a boolean to verify if transaction is executed, and number of confirmations
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }
    
    /// @notice array of transactions of type Transaction
    Transaction[] public transactions;
    /// @notice #mapping for each transaction at txIndex check if owner have confirmed it
    mapping(uint => mapping(address => bool));

    /// @notice we will need some modifier to apply to our functions
    /// #onlyOwner
    /// #notExecuted
    /// #notConfirmed
    /// #txExists

    modifier onlyOwner() public {
        /// @notice we created isOwner mapping for this specific reason
        require(isOwner[msg.sender], "Not an owner");
        _;
    }
    modifier notExecuted(uint _txIndex) public {
        /// @notice the goal is to check if a transaction.executed is true or false
        require(!transactions[_txIndex].executed, "Already executed" );
        _;
    }
    modifier notConfirmed(uint _txIndex) public {
        require(!isConfirmed[_txIndex][msg.sender], "Already confirmed");
        _;
    }
    modifier txExists(uint _txIndex) public {
        require(_txIndex < transactions.length, "tx does not exist");
    }

    /// @notice constuctor takes in an array of owners stored in memory, an a minimal numbers of confirmations required
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        /// first thing we do is to check if the input are valid
        require(_owners.length > 0, "Not a valid input");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired < _owners.length, "Invalid number");

        for (uint i = 0; i <_owners.length; i++) {
            
            address owner = _owners[i];
            /// @dev owner cannot be address 0
            require(_owners[i] != address(0), "Cannot be address null");
            require(!isOwner[_owners[i]], "owner is not unique");
            /// @notice after passing the two require statement set
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    } 

    /// @notice now our functions
    receive () external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction (address _to, uint _value, bytes memory _data) public onlyOwner {
        uint txIndex = transactions.length;
        transactions.push(
            Transaction({
               to: _to,
               value: _value,
               data: _data,
               executed: false,
               numConfirmations: 0
            })
        );
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }
    
    function confirmTransaction(uint _txIndex)
    public
    onlyOwner
    notConfirmed(_txIndex)
    notExecuted(_txIndex)
    txExists(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        /// @notice first we check if we have the number of confirmations required on this transaction
        require(transaction.numConfirmations = numConfirmationsRequired, "Not enough confirmations");
        /// set transactions[_txIndex] to true
        transaction.executed = true;
        
        (bool success, ) = transaction.to.call({value: transaction.value})(transaction.data);
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }
}