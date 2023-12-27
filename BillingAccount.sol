// SPDX-License-Identifier: BSD-2-Clause
pragma solidity ^0.8.22;

contract BillingAccount {
    mapping(address => uint) public accounts;

    function deposit() public payable {
        accounts[msg.sender] += msg.value;
    }

    receive() external payable {
        accounts[msg.sender] += msg.value;
    }

    fallback() external payable {
        accounts[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        accounts[msg.sender] -= amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "Failed to send Ether");
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier privileged() {
        require(msg.sender == owner, "Privileged function");
        _;
    }

    event Charged(string invoice);

    function charge(address user, uint amount, string calldata invoice) public privileged {
        accounts[user] -= amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "Failed to send Ether");
        emit Charged(invoice);
    }

    address public proposedNewOwner;

    function proposeNewOwner(address newOwner) public privileged {
        proposedNewOwner = newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == proposedNewOwner, "Not the proposed owner");
        owner = proposedNewOwner;
    }
}