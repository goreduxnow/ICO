// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnerWithdrawable is Ownable {
    using SafeMath for uint256;

    receive() external payable {}

    fallback() external payable {}

    function withdraw(address token, uint256 amt) public onlyOwner {
        IERC20(token).transfer(msg.sender, amt);
    }
    function withdrawCurrency(uint256 amt) external onlyOwner {
        payable(msg.sender).transfer(amt);
    }
    function getCurrencyBalance()external view returns(uint256){
        return (address(this).balance);
    }

}
