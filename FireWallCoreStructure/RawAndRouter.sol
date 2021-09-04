// SPDX-License-Identifier: MIT
/// @title RawAndRouter -- RawAndRouter
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LDecoder} from "./LDecoder.sol";
import {LRawAndRouter} from "./LRawAndRouter.sol";
import {IDecoder} from "./IDecoder.sol";
import {IRelayModule} from "./IRelayModule.sol";
import {IFilterProcess} from "./IFilterProcess.sol";
contract RawAndRouter{

    //================Enum================
    LRawAndRouter.RawChoice rawChoice;
    LRawAndRouter.RouteChoice routeChoice;
    //================Tables================
    LRawAndRouter.RawTable[] rawTables;
    LRawAndRouter.RouteTable[] routeTables;
    LRawAndRouter.RelayTable[] relayTables;
    //================RelayModules================
    address[] relayModules;
    //=================Storage Data(Params and Transaction muse be INITIALIZED=====================
    mapping(string=>LDecoder.FunctionParamsValue) params;//all param mapping
    LDecoder.Transaction transaction;

    //=====================event======================
    //TODO: add event list


    //================Initializer================
    address DECODER_ADDRESS;
    address FILTER_ADDRESS;
    function Initialize(address DecoderAddress,address FilterAddress) external{
        DECODER_ADDRESS=DecoderAddress;
        FILTER_ADDRESS=FilterAddress;
    }
    //================startFireWall================
    function activeFireWall() external returns(bool){
        //TODO:this active function logic need to look back

        //**********Initialize the latest trasaction and param Data**********
        transaction=IDecoder(DECODER_ADDRESS).getTransaction();
        string[] memory allParamsName=IDecoder(DECODER_ADDRESS).getAllParamName();
        packageParams(allParamsName);

        //**********Raw Process**********
        //enum RawChoice { banned,letThrough,UNKNOWN}
        bool rslt=true;
        (rslt,rawChoice)=LRawAndRouter.checkTransactionIfMatchBasedRawTable(transaction,rawTables);
        require(rslt,"RawTables banned");//Tx be banned
        if(rawChoice==LRawAndRouter.RawChoice.letThrough) return true;//Tx will skip all after-check(letThrough) and direct to logic function

        //**********Router Process**********
        //enum RouteChoice { FilterAndRelay,FilterNotRelay,NotFilterRelay,UNKNOWN}
        (rslt,routeChoice)=LRawAndRouter.checkTransactionIfMatchBasedRouteTable(transaction,routeTables);
        if(routeChoice==LRawAndRouter.RouteChoice.FilterAndRelay){
            (rslt,relayModules)=LRawAndRouter.checkTransactionIfMatchBasedRelayTable(transaction,relayTables);
            if(rslt){
                doRelay(relayModules);
                IFilterProcess(FILTER_ADDRESS).activeFilterProcess();
            }
        }
        if(routeChoice==LRawAndRouter.RouteChoice.NotFilterRelay){
            (rslt,relayModules)=LRawAndRouter.checkTransactionIfMatchBasedRelayTable(transaction,relayTables);
            if(rslt){
                doRelay(relayModules);
            }
        }
        if(routeChoice==LRawAndRouter.RouteChoice.FilterNotRelay){
            IFilterProcess(FILTER_ADDRESS).activeFilterProcess();
        }
        if(routeChoice==LRawAndRouter.RouteChoice.UNKNOWN){}

    }

    function doRelay(address[] memory relayModules) internal {
        for(uint i=0;i<relayModules.length;i++){
            IRelayModule(relayModules[i]).activeRelayModule();
        }

    }
    function addRawTable(bytes4 msgSig,string memory funName,address msgSender,address Origin,LRawAndRouter.RawChoice choice) external {
        rawTables=LRawAndRouter.addRawTable(rawTables,msgSig,funName,msgSender,Origin,choice);
    }
    function addRouteTable(bytes4 msgSig,string memory funName,address msgSender,address Origin,LRawAndRouter.RouteChoice choice) external {
        routeTables=LRawAndRouter.addRouteTable(routeTables,msgSig,funName,msgSender,Origin,choice);
    }
    // addRelayTable(RelayTable[] storage tables,bytes4 msgSig,string memory funName,address msgSender,address Origin,address[] memory relayModules)
    function addRouteTable(bytes4 msgSig,string memory funName,address msgSender,address Origin,address[] memory relayModules) external {
        relayTables=LRawAndRouter.addRelayTable(relayTables,msgSig,funName,msgSender,Origin,relayModules);
    }
    //================tool Function=====================
    //Params Package
    function packageParams(string[] memory allParamsName) public{
        for(uint i=0;i<allParamsName.length;i++){
            params[allParamsName[i]]=IDecoder(DECODER_ADDRESS).getParam(allParamsName[i]);
        }
    }


}