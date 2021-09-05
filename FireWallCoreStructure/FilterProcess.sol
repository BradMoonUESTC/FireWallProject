// SPDX-License-Identifier: MIT
/// @title FilterProcess -- FilterProcess
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LFilterProcess} from "./LFilterProcess.sol";
import {LDecoder} from "./LDecoder.sol";
import {IDecoder} from "./IDecoder.sol";
import {IFilterModule} from "./IFilterModule.sol";
contract FilterProcess {


    //================Tables================
    LFilterProcess.Strategy[] strategies;
    
    //=================Storage Data(Params and Transaction muse be INITIALIZED=====================
    mapping(string=>LDecoder.FunctionParamsValue) params;//all param mapping
    LDecoder.Transaction transaction;
    
    //================Initializer================
    address DECODER_ADDRESS;
    function Initialize(address DecoderAddress) external{
        DECODER_ADDRESS=DecoderAddress;
    }
    
    //================Strategy modules================
    address[] Modules;
    
    //=====================event======================
	//TODO: add event list
	
    //=====================Filter core Process======================
    function activeFilterProcess() external returns(bool,string memory,string memory){
        //**********Initialize the latest trasaction and param Data**********
        transaction=IDecoder(DECODER_ADDRESS).getTransaction();
        string[] memory allParamsName=IDecoder(DECODER_ADDRESS).getAllParamName();
        packageParams(allParamsName);
        
        //**********check Strategy**********
        bool rslt=true;
        bool aggregateRslt=true;
        (rslt,Modules)=LFilterProcess.checkTransactionIfMatchBasedStrategy(transaction,strategies);
        
        //**********filter Process**********
        for(uint i=0;i<Modules.length;i++){
            //TODO:check moduletype , ensure they run different interface function
            //TODO:different moduleType NEED to return differnt result and use
            IFilterModule(Modules[i]).activeDataAggregatorModule();

            aggregateRslt=aggregateRslt&&IFilterModule(Modules[i]).activeFilterModule();
            
            IFilterModule(Modules[i]).activeRiskEstimateModule();
        }
        require(aggregateRslt,"attack found");
        //TODO:need to look back AND add returns value
    }
	

	//================tool Function=====================
     //Params Package
    function packageParams(string[] memory allParamsName) public{
        for(uint i=0;i<allParamsName.length;i++){
            params[allParamsName[i]]=IDecoder(DECODER_ADDRESS).getParam(allParamsName[i]);
        }
    }
    
}
