// SPDX-License-Identifier: MIT
/// @title LRawAndRouter -- LRawAndRouter
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LDecoder} from "./LDecoder.sol";
library LRawAndRouter{

    // struct Transaction {
    //     address msgSender;
    //     address txOrigin;
    //     bytes4 msgSig;
    //     uint msgValue;
    //     string funName;
    // }
    enum RawChoice { banned,letThrough,UNKNOWN}
    enum RouteChoice { FilterAndRelay,FilterNotRelay,NotFilterRelay,UNKNOWN}
    //=====================struct======================
    struct RawTable {
        bytes4 msgSig;
        string funName;
        address msgSender;
        address txOrigin;
        RawChoice choice;
    }

    struct RouteTable {
        bytes4 msgSig;
        string funName;
        address msgSender;
        address txOrigin;
        RouteChoice choice;
    }

    struct RelayTable {
        bytes4 msgSig;
        string funName;
        address msgSender;
        address txOrigin;

        address[] relayModules;


    }

    //=====================event======================
    //TODO: add event list

    //TODO: every OP Table function need to recheck and optimize the code
    //=====================OP RawTable======================
    function checkTransactionIfMatchBasedRawTable(LDecoder.Transaction memory tx,RawTable[] memory tables) external returns(bool,RawChoice){
        for(uint i=0;i<tables.length;i++){
            RawTable memory table=tables[i];
            if((tx.msgSig==table.msgSig||hashCompareInternal(tx.funName,table.funName))){
                if(tx.msgSender==table.msgSender||tx.txOrigin==table.txOrigin){
                    if(table.choice==RawChoice.banned){
                        return (false,table.choice);
                    }
                    if(table.choice==RawChoice.letThrough){
                        return (true,table.choice);
                    }
                    //TODO: this check need to LOOK BACK
                }
            }
        }
        return (true,RawChoice.UNKNOWN);
    }

    function addRawTable(RawTable[] storage tables,bytes4 msgSig,string memory funName,address msgSender,address txOrigin,RawChoice choice) external returns(RawTable[] storage){
        RawTable memory table=RawTable(msgSig,funName,msgSender,txOrigin,choice);
        tables.push(table);
        return tables;
    }

    function modifyRawTable(uint index,RawTable[] storage tables,bytes4 newMsgSig,string memory newFunName,address newMsgSender,address newTxOrigin,RawChoice choice) external returns (RawTable[] storage) {
        if(newMsgSig!=0x000000){
            tables[index].msgSig=newMsgSig;
        }
        //TODO: add modify code
        return tables;
    }
    //delete RawTable at index
    function removeRawTablesAtIndex(uint index,RawTable[] storage tables) external returns (RawTable[] storage) {
        if (index >= tables.length) return tables;

        for (uint i = index; i < tables.length-1; i++) {
            tables[i] = tables[i+1];
        }

        delete tables[tables.length-1];
        return tables;
    }

    //=====================OP RouteTable======================
    function checkTransactionIfMatchBasedRouteTable(LDecoder.Transaction memory tx,RouteTable[] memory tables) external returns(bool,RouteChoice){
        for(uint i=0;i<tables.length;i++){
            RouteTable memory table=tables[i];
            if((tx.msgSig==table.msgSig||hashCompareInternal(tx.funName,table.funName))){
                if(tx.msgSender==table.msgSender||tx.txOrigin==table.txOrigin){
                    return (true,table.choice);
                    //TODO: this check need to LOOK BACK
                }
            }
        }
        return (true,RouteChoice.UNKNOWN);
    }
    function addRouteTable(RouteTable[] storage tables,bytes4 msgSig,string memory funName,address msgSender,address txOrigin,RouteChoice choice) external returns(RouteTable[] storage){
        RouteTable memory table=RouteTable(msgSig,funName,msgSender,txOrigin,choice);
        tables.push(table);
        return tables;
    }
    //delete RouteTable at index
    function removRouteTablesAtIndex(uint index,RouteTable[] storage tables) external returns (RouteTable[] storage) {
        if (index >= tables.length) return tables;

        for (uint i = index; i < tables.length-1; i++) {
            tables[i] = tables[i+1];
        }

        delete tables[tables.length-1];
        return tables;
    }
    //=====================OP RelayTable======================
    function checkTransactionIfMatchBasedRelayTable(LDecoder.Transaction memory tx,RelayTable[] memory tables) external returns(bool,address[] memory){
        for(uint i=0;i<tables.length;i++){
            RelayTable memory table=tables[i];
            if((tx.msgSig==table.msgSig||hashCompareInternal(tx.funName,table.funName))){
                if(tx.msgSender==table.msgSender||tx.txOrigin==table.txOrigin){
                    return (true,table.relayModules);
                    //TODO: this check need to LOOK BACK
                }
            }
        }
        address[] memory emptyAddress;
        emptyAddress[0]=address(0);
        return (false,emptyAddress);
    }
    function addRelayTable(RelayTable[] storage tables,bytes4 msgSig,string memory funName,address msgSender,address txOrigin,address[] memory relayModules) external returns(RelayTable[] storage){
        RelayTable memory table=RelayTable(msgSig,funName,msgSender,txOrigin,relayModules);
        tables.push(table);
        return tables;
    }
    //delete RouteTable at index
    function removRelayTablesAtIndex(uint index,RelayTable[] storage tables) external returns (RelayTable[] storage) {
        if (index >= tables.length) return tables;

        for (uint i = index; i < tables.length-1; i++) {
            tables[i] = tables[i+1];
        }

        delete tables[tables.length-1];
        return tables;
    }
    //=====================tool function======================
    function hashCompareInternal(string memory a, string memory b) internal returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

}