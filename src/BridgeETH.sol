// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BridgeETH is Ownable {
    address public tokenAddress;
    uint256 public balance;
    event Deposit(address indexed depositer, uint amount);
    mapping(address => uint256) public pendingBalance;

    constructor(address _tokenAddress) Ownable(msg.sender) {
        tokenAddress = _tokenAddress;
    }

    function lock(IERC20 _token, uint256 _amount) public {
        require(
            address(_token) == tokenAddress,
            "This contract doesn't support this token"
        );
        require(_token.allowance(msg.sender, address(this)) >= _amount);
        require(_token.transferFrom(msg.sender, address(this), _amount));
        pendingBalance[msg.sender] += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function unlock(IERC20 _token, uint256 _amount) public {
        require(pendingBalance[msg.sender] >= _amount);
        pendingBalance[msg.sender] -= _amount;
        _token.transfer(msg.sender, _amount);
    }

    function burnedOnOtherSide(
        address _user,
        uint256 _amount
    ) public onlyOwner {
        pendingBalance[_user] += _amount;
    }
}
