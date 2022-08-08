// SPDX-License-Identifier: MIT License

pragma solidity 0.8.15;

contract SimpleBank{
    address public Owner;
    constructor(){
        Owner = msg.sender;
    }
    mapping (address => uint) private balances;
    event depositmode (address depositer , uint amount);

    modifier NotZero(){
        require ( (balances[msg.sender]+msg.value) >= balances[msg.sender]);
        _;
    }
    modifier InsufficientBalance(uint WithdrawAmount){
        require ( WithdrawAmount <= balances[msg.sender] , "Your Balance Is Not Insufficient");
        _;
    }
    function deposit() public payable NotZero returns(uint){
    balances[msg.sender] += msg.value;
    emit depositmode (msg.sender , msg.value);
    return balances[msg.sender];
    }
    function withdraw(uint WithdrawAmount) public payable InsufficientBalance(WithdrawAmount) returns(uint remainingBal){
        balances[msg.sender] -= WithdrawAmount;
        payable (msg.sender).transfer(WithdrawAmount);
        return balances[msg.sender];
    }
    function balance() view public returns(uint){
        return balances[msg.sender];
    }
}