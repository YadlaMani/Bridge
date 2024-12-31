// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MPanda is ERC20, Ownable {
    constructor() ERC20("MPanda", "MPAD") Ownable(msg.sender) {}

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _of, uint256 _amount) public onlyOwner {
        _burn(_of, _amount);
    }
}
