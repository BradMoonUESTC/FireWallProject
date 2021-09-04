// SPDX-License-Identifier: MIT
/// @title TxFilterProcess -- TxFilterProcess
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LTxFilterProcess} from "./LTxFilterProcess.sol";
import {LTxDecoder} from "./LTxDecoder.sol";
import {ITxDecoder} from "./ITxDecoder.sol";
import {IFilterModule} from "./IFilterModule.sol";
contract TxFilterProcess {


    //================Tables================
    LTxFilterProcess.Strategy[] strategies;
    
    //=================Storage Data(Params and Transaction muse be INITIALIZED=====================
    mapping(string=>LTxDecoder.FunctionParamsValue) params;//all param mapping
    LTxDecoder.Transaction transaction;
    
    //================Initializer================
    address DECODER_ADDRESS;
    function Initialize(address DecoderAddress) external{
        DECODER_ADDRESS=DecoderAddress;
    }
    
    //================Strategy modules================
    address[] Modules;
    
    //=====================Filter core Process======================
    function activeFilterProcess() external returns(bool,string memory,string memory){
        //**********Initialize the latest trasaction and param Data**********
        transaction=ITxDecoder(DECODER_ADDRESS).getTransaction();
        string[] memory allParamsName=ITxDecoder(DECODER_ADDRESS).getAllParamName();
        packageParams(allParamsName);
        
        //**********check Strategy**********
        bool rslt=true;
        bool aggregateRslt=true;
        (rslt,Modules)=LTxFilterProcess.checkTransactionIfMatchBasedStrategy(transaction,strategies);
        //**********filter Process**********
        for(uint i=0;i<Modules.length;i++){
            //TODO:check moduletype to run different interface function
            //TODO:different moduleType NEED to return differnt result and use
            aggregateRslt=aggregateRslt&&IFilterModule(Modules[i]).activeFilterModule();
            IFilterModule(Modules[i]).activeDataAggregatorModule();
            IFilterModule(Modules[i]).activeRiskEstimateModule();
        }
        require(aggregateRslt,"attack found");
        //TODO:need to look back AND add returns value
    }
	
	//=====================event======================
	//TODO: add event list
	
	//================tool Function=====================
     //Params Package
    function packageParams(string[] memory allParamsName) public{
        for(uint i=0;i<allParamsName.length;i++){
            params[allParamsName[i]]=ITxDecoder(DECODER_ADDRESS).getParam(allParamsName[i]);
        }
    }
    
}
