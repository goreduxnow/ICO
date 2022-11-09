// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnerWithdrawable is Ownable {
    using SafeMath for uint256;

    receive() external payable {}

    fallback() external payable {}

    function withdrawCurrency(uint256 amt) public onlyOwner {
        payable(msg.sender).transfer(amt);
    }
    function getCurrencyBalance()public view returns(uint256){
        return (address(this).balance);
    }

}