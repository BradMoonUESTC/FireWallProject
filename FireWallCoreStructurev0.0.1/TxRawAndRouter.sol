// SPDX-License-Identifier: MIT
/// @title TxRawAndRouter -- TxRawAndRouter
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LTxDecoder} from "./LTxDecoder.sol";
import {LTxRawAndRouter} from "./LTxRawAndRouter.sol";
import {ITxDecoder} from "./ITxDecoder.sol";
contract TxRawAndRouter{

    //================Enum================
    LTxRawAndRouter.RawChoice rawChoice;
    LTxRawAndRouter.RouteChoice routeChoice;
    //================Tables================
    LTxRawAndRouter.RawTable[] rawTables;
    LTxRawAndRouter.RouteTable[] routeTables;
    LTxRawAndRouter.RelayTable[] relayTables;
    //================RelayModules================
    address[] relayModules;
    //=================Storage Data(Params and Transaction muse be INITIALIZED=====================
    mapping(string=>LTxDecoder.FunctionParamsValue) params;//all param mapping
    LTxDecoder.Transaction transaction;
    
    
    
    //================Initializer================
    address DECODER_ADDRESS;
    function Initialize(address DecoderAddress) external{
        DECODER_ADDRESS=DecoderAddress;
    }
    //================startFireWall================
    function activeFireWall() external returns(bool){
        //**********Initialize the latest trasaction and param Data**********
        transaction=ITxDecoder(DECODER_ADDRESS).getTransaction();
        string[] memory allParamsName=ITxDecoder(DECODER_ADDRESS).getAllParamName();
        packageParams(allParamsName);
        //**********Raw Process**********
        //enum RawChoice { banned,letThrough,UNKNOWN}
        bool rslt=true;
        (rslt,rawChoice)=LTxRawAndRouter.checkTransactionIfMatchBasedRawTable(transaction,rawTables);
        require(rslt,"RawTables banned");//banned process
        if(rawChoice==LTxRawAndRouter.RawChoice.letThrough) return true;//letThrough process
        
        //**********Router Process**********
        //enum RouteChoice { FilterAndRelay,FilterNotRelay,NotFilterRelay,UNKNOWN}
        (rslt,routeChoice)=LTxRawAndRouter.checkTransactionIfMatchBasedRouteTable(transaction,routeTables);
        if(routeChoice==LTxRawAndRouter.RouteChoice.FilterAndRelay){
            (rslt,relayModules)=LTxRawAndRouter.checkTransactionIfMatchBasedRelayTable(transaction,relayTables);
            if(rslt){//TODO:do relay
            }
        }
        if(routeChoice==LTxRawAndRouter.RouteChoice.NotFilterRelay){
            (rslt,relayModules)=LTxRawAndRouter.checkTransactionIfMatchBasedRelayTable(transaction,relayTables);
            if(rslt){//TODO:do relay
            }
        }
        if(routeChoice==LTxRawAndRouter.RouteChoice.FilterNotRelay){
            
        }
        if(routeChoice==LTxRawAndRouter.RouteChoice.UNKNOWN){}
    }
    
    
    function addRawTable(bytes4 msgSig,string memory funName,address msgSender,address txOrigin,LTxRawAndRouter.RawChoice choice) external {
        rawTables=LTxRawAndRouter.addRawTable(rawTables,msgSig,funName,msgSender,txOrigin,choice);
    }
    function addRouteTable(bytes4 msgSig,string memory funName,address msgSender,address txOrigin,LTxRawAndRouter.RouteChoice choice) external {
        routeTables=LTxRawAndRouter.addRouteTable(routeTables,msgSig,funName,msgSender,txOrigin,choice);
    }
    // addRelayTable(RelayTable[] storage tables,bytes4 msgSig,string memory funName,address msgSender,address txOrigin,address[] memory relayModules)
    function addRouteTable(bytes4 msgSig,string memory funName,address msgSender,address txOrigin,address[] memory relayModules) external {
        relayTables=LTxRawAndRouter.addRelayTable(relayTables,msgSig,funName,msgSender,txOrigin,relayModules);
    }
    //================tool Function=====================
     //Params Package
    function packageParams(string[] memory allParamsName) public{
        for(uint i=0;i<allParamsName.length;i++){
            params[allParamsName[i]]=ITxDecoder(DECODER_ADDRESS).getParam(allParamsName[i]);
        }
    }
    
    
}