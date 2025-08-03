// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SmartWallet {
    address public owner;
    mapping(address => bool) public isApproved;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    event ApprovalGranted(address indexed approved);
    event ApprovalRevoked(address indexed revoked);
    event Executed(address indexed to, uint256 value, bytes data, bool success);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyApproved() {
        require(msg.sender == owner || isApproved[msg.sender], "Not authorized");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    // ✅ New: Deposit ETH explicitly via function
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH");
        emit Deposit(msg.sender, msg.value);
    }

    // 🔄 Existing: Deposit via plain ETH transfer (e.g. send from wallet)
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // ✅ New: Withdraw ETH to any address, any amount
    function withdraw(address payable _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
        emit Withdrawal(_to, _amount);
    }

    // 🔐 Approval system for trusted senders
    function approve(address _addr) external onlyOwner {
        isApproved[_addr] = true;
        emit ApprovalGranted(_addr);
    }

    function revoke(address _addr) external onlyOwner {
        isApproved[_addr] = false;
        emit ApprovalRevoked(_addr);
    }

    // ✅ Execute calls to other contracts (DeFi, etc)
    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyApproved returns (bool success, bytes memory result) {
        (success, result) = _to.call{value: _value}(_data);
        emit Executed(_to, _value, _data, success);
    }

    // ✅ Get current ETH balance of wallet
    function GetBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

