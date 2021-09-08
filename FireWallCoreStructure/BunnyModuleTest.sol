// SPDX-License-Identifier: MIT
/// @title BunnyModuleTest -- BunnyModuleTest
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {IDataCenter} from "./IDataCenter.sol";
import {IVaultFlipToFlip} from "./IVaultFliptoFlip.sol";
import {IDecoder} from "./IDecoder.sol";
import "./SafeMath.sol";
import "./StringTool.sol";
contract BunnyModuleTest is StringTool{
    using SafeMath for uint;
    address DATACENTER;
    address YieldAggregatorAddress;
    address DECODER;
    //================Initializer================
    function Initialize(address dataCenter) external{
        DATACENTER=dataCenter;
        DECODER=IDataCenter(DATACENTER).getDecoderAddress();
    }
    function activeFilterModule() external returns(bool){
        bool rslt=true;
        YieldAggregatorAddress=IDataCenter(DATACENTER).getAggregatorAddress("VaultCakeBNB");
        address msgSender=IDecoder(DECODER).getTxSender();
        address txOrigin=IDecoder(DECODER).getTxOrigin();
        string memory funName=IDecoder(DECODER).getTxFunName();
        if(checkIfEarned(msgSender)||checkIfEarned(txOrigin)){
            if(hashCompareInternal(funName,"getReward()")){
                return IDataCenter(DATACENTER).checkPrice("BUNNYBNB", 3);
            }
            
        }
        return rslt;
    }
    //example of filter,consider move to module

    function checkIfEarned(address account) internal returns(bool){
        return IVaultFlipToFlip(YieldAggregatorAddress).earned(account)>0;
    }
}