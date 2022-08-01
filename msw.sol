// SPDX-License-Identifier: MIT License

pragma solidity 0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract MSW is Ownable{

    event deposit (address indexed sender, uint amount , uint balance);
    event submittransaction (address indexed owner , uint indexed txindex , address indexed to );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address [] public owners;
    mapping (address => bool) public isOwner;
    uint public ncr;
    string password;

    enum status {wating , submited , confirmed , executed}

    struct transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint nc;
        status st;
    }
    mapping (uint =>mapping (address => bool)) public isconfermed;

    transaction [] public transactions;

    modifier onlyowner() {
        require(isOwner[msg.sender]);
        _;
    }

    modifier txexits(uint _txindex){
        require(_txindex < transactions.length);
        _;
    }
    modifier notexcuted(uint _txindex){
        require(!transactions[_txindex].executed);
        _;
    }
    modifier notconfirmed (uint _txindex){
        require(!isconfermed[_txindex][msg.sender]);
        _;
    }
    constructor (address [] memory _owners , uint _ncr , string memory _password){
        require(_owners.length>0);
        require(_ncr<=_owners.length && _ncr>0);
        for (uint i = 0 ; i < _owners.length; i ++){
            address owner = _owners[i];
            require( owner != address(0));
            require (!isOwner[owner]);
            isOwner[owner]=true;
            owners.push(owner);
        }
        ncr=_ncr;
        password = _password;
    }

    receive() external payable{
        emit deposit(msg.sender,msg.value, address(this).balance);
    }

    function SubmitTransaction(address _to,uint _value, bytes memory _data) public payable onlyowner{
        require(msg.value >= 1 ether);
        uint txindex = transactions.length;
        transactions.push(transaction({to : _to , value : _value , data : _data , executed : false , nc : 0 , st : status.submited }));
        emit submittransaction(msg.sender , txindex , _to);
    }
    function confirmtransaction (uint _txindex) public onlyowner txexits(_txindex) notexcuted(_txindex) notconfirmed(_txindex) {
        transaction storage trx = transactions[_txindex];
        trx.nc ++ ;
        trx.st = status.confirmed;
        isconfermed [_txindex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender , _txindex);
    }
 
    function executetransaction (uint _txindex , string calldata pass) public onlyowner txexits(_txindex) notexcuted(_txindex){
        require ( keccak256(abi.encodePacked(pass)) == keccak256(abi.encodePacked(password)) );
        transaction storage trx = transactions[_txindex];
        require(trx.nc >= ncr);
        (bool c, ) = trx.to.call{value : trx.value}(trx.data);
        trx.executed=true;
        trx.st = status.executed;
        require (c,"trx failed");
        emit ExecuteTransaction(msg.sender,_txindex);
    }
    
    function revokeconfirmation (uint _txindex) public onlyowner txexits(_txindex) notexcuted(_txindex){
       transaction storage trx = transactions[_txindex];
       require (isconfermed[_txindex][msg.sender]);
       trx.nc -- ;
       isconfermed [_txindex][msg.sender] = false;
       emit RevokeConfirmation (msg.sender,_txindex);
    }
    
    function gettransaction(uint _txindex) public view returns(address , uint , bytes memory , bool , uint){
        transaction memory trx = transactions[_txindex];

        return (trx.to , trx.value , trx.data , trx.executed , trx.nc);

    }

    function getbalance () public view returns(uint){
        return IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).balanceOf(msg.sender);
    }

}


