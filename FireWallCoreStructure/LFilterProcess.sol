// SPDX-License-Identifier: MIT
/// @title LFilterProcess -- LFilterProcess
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LDecoder} from "./LDecoder.sol";
import {IDecoder} from "./IDecoder.sol";
library LFilterProcess {

    //=====================enum========================
    enum ModuleType { DataAggregator,DataPattern,RiskEstimate,UNKNOWN }
    enum ModuleStatus { Enable,Disable }
    enum StrategyStatus { Enable,Disable }
    //=====================struct======================

    struct Module{
        uint moduleId;

    }

    struct ModuleRegistInfo{
        ModuleType moduleType;
        address moduleAddress;
        string moduleName;
        address moduleRegister;
        string moduleRegisterName;
        uint moudleId;
        ModuleStatus moduleStatus;

    }
    struct Strategy{
        address msgSender;
        address txOrigin;
        bytes4 msgSig;
        uint msgValue;
        string funName;

        string strategyRegistName;
        string strategyRegistDate;
        string[] moduleName;
        address[] moduleAddress;

    }

    //=====================OP Strategy======================
    function checkTransactionIfMatchBasedStrategy(LDecoder.Transaction memory tx,Strategy[] memory tables) external returns(bool,address[] memory){
        for(uint i=0;i<tables.length;i++){
            Strategy memory table=tables[i];
            if((tx.msgSig==table.msgSig||hashCompareInternal(tx.funName,table.funName))){
                if(tx.msgSender==table.msgSender||tx.txOrigin==table.txOrigin){
                    return (true,table.moduleAddress);
                    //TODO: this check need to LOOK BACK
                }
            }
        }
    }
    function addStrategy(Strategy[] storage tables,Strategy memory table) external returns(Strategy[] storage){
        tables.push(table);
        return tables;
        //TODO:need to add function of add with param
    }
    //delete RouteTable at index
    function removStrategyAtIndex(uint index,Strategy[] storage tables) external returns (Strategy[] storage) {
        if (index >= tables.length) return tables;

        for (uint i = index; i < tables.length-1; i++) {
            tables[i] = tables[i+1];
        }

        delete tables[tables.length-1];
        return tables;
    }
    //=====================event======================
    //TODO: add event list
    //=====================tool function======================
    function hashCompareInternal(string memory a, string memory b) internal returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

}
