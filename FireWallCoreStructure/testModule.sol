// SPDX-License-Identifier: MIT
/// @title testModule -- testModule
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LDecoder} from "./LDecoder.sol";
import {LRawAndRouter} from "./LRawAndRouter.sol";
import {IDecoder} from "./IDecoder.sol";
import {IRelayModule} from "./IRelayModule.sol";
import {IFilterProcess} from "./IFilterProcess.sol";
import "./StringTool.sol";
contract testModule is StringTool{


    // struct FunctionParamsValue{
    //     string paramType;
        
    //     string stringParamValue;
    //     uint256 uintParamValue;
    //     address addressParamValue;
    //     bool boolParamValue;
    //     string[] stringArrrayParamValue;
    //     uint256[] uintArrayParamValue;
    //     address[] addressArrayParamValue;
    //     bool[] boolArrayParamValue;
    // }
    //=================Storage Data(Params and Transaction muse be INITIALIZED=====================
    mapping(string=>LDecoder.FunctionParamsValue) params;//all param mapping
    LDecoder.Transaction transaction;

    //================Initializer================
    address DECODER_ADDRESS;
    address FILTER_ADDRESS;
    function Initialize(address DecoderAddress,address FilterAddress) external{
        DECODER_ADDRESS=DecoderAddress;
        FILTER_ADDRESS=FilterAddress;
    }
    function activeFilterModule() external returns(bool){
        //**********Initialize the latest trasaction and param Data**********
        transaction=IDecoder(DECODER_ADDRESS).getTransaction();
        string[] memory allParamsName=IDecoder(DECODER_ADDRESS).getAllParamName();
        packageParams(allParamsName);

        //**********doFilter**********
        LDecoder.FunctionParamsValue memory _key=params["_key"];
        if(hashCompareInternal(_key.paramType,"string")){
            string memory _key_value=_key.stringParamValue;
            if(!hashCompareInternal(_key_value,"aaa")){
                return false;
            }
        }
    }



    //================tool Function=====================
    //Params Package
    function packageParams(string[] memory allParamsName) public{
        for(uint i=0;i<allParamsName.length;i++){
            params[allParamsName[i]]=IDecoder(DECODER_ADDRESS).getParam(allParamsName[i]);
        }
    }
}