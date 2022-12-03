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
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

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
        require(_owners.length > 0, "No owners");
        ///  @notice only owners can confirm transactions
        /// so numConfirmationsRequired should be less or equal
        /// to total number of owners
        require(
            _numConfirmationsRequired > 0 &&
            _numConfirmationsRequired <= _owners.length,
            "Invalid number"
        );

        for(uint i= 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid address");
            require(!isOwner[owner], "owner not unique");
            isOwner[owner] = true;
            owners.push[owner];
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(address _to,
    uint _value,
    bytes memory _data
    ) public onlyOwner {
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
    txExists(_txIndex)
    notExecuted(_txIndex)
    notConfirmed(_txIndex)
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

        require(
            transaction.numConfirmations = numConfirmationsRequired,
            "Not enough confirmation"
        );
        
        transaction.executed = true;

        (bool success, ) = transaction.to.call({value: transaction.value})(transaction.data);
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
    public
    onlyOwner 
    txExists(_txIndex)
    notExecuted(_txIndex)
    {
       Transaction storage transaction = transactions[_txIndex];
       /// @notice tx must be already confirmed before revoking
       require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
       
       /// @notice reduce number of confirmations
       /// @dev set confirmation for the txindex to default 
       transaction.numConfirmations -= 1;
       isConfirmed[_txIndex][msg.sender] = false;

       emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view return (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
    public
    view
    returns (
    address to,
    uint value,
    bytes memory data,
    bool executed,
    uint numConfirmations  
    ) 
       {
        Transaction storage transaction = transactions[_txIndex];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}