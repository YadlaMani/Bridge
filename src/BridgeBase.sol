// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBUSDT is IERC20 {
    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}

contract BridgeBase is Ownable {
    uint256 public balance;
    address public tokenAddress;
    event Burn(address indexed burner, uint256 amount);
    event DepositRecorded(address indexed userAccount, uint256 amount);
    mapping(address => uint256) public pendingBalance;

    constructor(address _tokenAddress) Ownable(msg.sender) {
        tokenAddress = _tokenAddress;
    }

    function withdraw(address _user, IBUSDT _token, uint256 _amount) public {
        require(
            pendingBalance[_user] >= _amount,
            "Insufficient pending balance"
        );
        pendingBalance[_user] -= _amount;
        _token.mint(_user, _amount);
    }

    function burn(IBUSDT _token, uint256 _amount) public {
        require(address(_token) == tokenAddress, "Invalid token address");
        require(
            pendingBalance[msg.sender] >= _amount,
            "Insufficient pending balance"
        );
        _token.burn(msg.sender, _amount);
        emit Burn(msg.sender, _amount);
    }

    function depositedOnOtherSide(
        address userAccount,
        uint256 _amount
    ) public onlyOwner {
        pendingBalance[userAccount] += _amount;
        emit DepositRecorded(userAccount, _amount);
    }
}
