// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrantBank {
    
    struct User {
        uint256 balance;
        string name;
        string email;
    }

    mapping(address => User) private users;
    bool private locked;

    event Deposit(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyPayable() {
        require(msg.value > 0, "Ooops! you no get money dig head");
        _; 
    }

    modifier onlyWithdrawable(uint amount) {
        require(amount <= users[msg.sender].balance, "Ooole! You wan withdraw wetin you get");
        _; 
    }

    function makeDeposit() public payable onlyPayable{
        users[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawUserBal(uint256 amount) external noReentrancy onlyWithdrawable(amount){
        users[msg.sender].balance -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function retrieveUserBal() public view returns (uint256) {
        return users[msg.sender].balance;
    }
}