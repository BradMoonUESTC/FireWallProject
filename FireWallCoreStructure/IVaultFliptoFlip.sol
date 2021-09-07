// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
interface IVaultFlipToFlip {
    function totalSupply() external view returns (uint);
    function balance() external view returns (uint amount);
    function balanceOf(address account) external view returns(uint);
    function withdrawableBalanceOf(address account) external view returns (uint);
    function sharesOf(address account) external view returns (uint);
    function principalOf(address account) external view returns (uint);
    function earned(address account) external view returns (uint);
    function depositedAt(address account) external view returns (uint);
    function rewardsToken() external view returns (address);
    function priceShare() external view returns(uint);

    
}
