// contracts/BLMToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//@author:xy_bloodmoon in 20210505
//note:this is a example that the protocol ERC20 has a reentrancy vulnerability
//the core problem in line 68 which call to line 48-49
//it`s due to that if you want to exchange 10 pooltoken via 10 BLMToken,but this vul will make to 5 blmtoken
//PS:of course it can be seen as a simple example of ERC20
//if u want to make this vul happen ,dont forget to approve the allowance!!!
//PPS:this vul will happen in ERC777!!!
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
contract BLMToken is ERC20 {
    address owner;
    //BloodMoon is name of this token,BLM is symbol of this token
    constructor() ERC20("BloodMoon", "TESTB") {
        //this action means contract will initialSupply BLMToken to the deployer
        _mint(msg.sender, 10**29);
        //owner=msg.sender;
    }
    
    // function mintForDepositer() public payable{
    //     uint256 sendToken=msg.value*(10**5);
    //     //if msg.sender give 1 ether to the token contract
    //     //the contract will give 10 token to the sender
    //     _mint(msg.sender,sendToken);
        
    // }
    
    // function ownerWithdraw() public payable{
    //     require(msg.sender==owner);
    //     payable(msg.sender).transfer(address(this).balance);
    // }
}