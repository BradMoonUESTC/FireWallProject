// SPDX-License-Identifier: MIT
/// @title Decoder -- Decoder
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LDecoder} from "./LDecoder.sol";
import "./StringTool.sol";
contract Decoder is StringTool{

    //=================Default Data=====================
    string constant DEFAULT_string ="";
    uint256 constant DEFAULT_uint=0;
    address constant DEFAULT_address=address(0);
    bool constant DEFAULT_bool=true;
    
    string[] DEFAULT_stringArrray;
    uint256[] DEFAULT_uintArray;
    address[] DEFAULT_addressArray;
    bool[] DEFAULT_boolArray;
    
    // struct Transaction {
    //     address msgSender;
    //     address txOrigin;
    //     bytes4 msgSig;
    //     uint msgValue;
    //     string funName;
    // }
    //=================Storage Data=====================
    mapping(string=>LDecoder.FunctionParamsValue) params;//all param mapping（name=>)
    LDecoder.Transaction transaction;
    string[] allParamName;
    
    //=====================event======================
	//TODO: add event list
    
    //=================getter and setter=====================
    
    function setParam(string memory paramsName,LDecoder.FunctionParamsValue memory param) external {
        params[paramsName]=param;
    }
    function getParam(string memory paramsName) external view returns(LDecoder.FunctionParamsValue memory param){
        return params[paramsName];
    }
    
    function setTransaction(address msgSender,address txOrigin,bytes4 msgSig,uint msgValue,string memory funName) external{
        transaction.msgSender=msgSender;
        transaction.txOrigin=txOrigin;
        transaction.msgSig=msgSig;
        transaction.msgValue=msgValue;
        transaction.funName=funName;
    }
    function getTransaction() external view returns(LDecoder.Transaction memory) {
        return transaction;
    }
    function addParamNameToArray(string memory newName) external{
        allParamName.push(newName);
    }
    function getAllParamName() external view returns(string[] memory){
        return allParamName;
    }
    
    //=================param op function=====================
    //TODO: param op function can be optimized
    function PackageParam(
        string memory paramType,
        string memory stringParamValue,
        uint256 uintParamValue,
        address addressParamValue,
        bool boolParamValue,
        string[] memory stringArrrayParamValue,
        uint256[] memory uintArrayParamValue,
        address[] memory addressArrayParamValue,
        bool[] memory boolArrayParamValue) private returns(LDecoder.FunctionParamsValue memory){
            LDecoder.FunctionParamsValue memory functionParamsValue=LDecoder.FunctionParamsValue(
                paramType,
                DEFAULT_string,
                DEFAULT_uint,
                DEFAULT_address,
                DEFAULT_bool,
                DEFAULT_stringArrray,
                DEFAULT_uintArray,
                DEFAULT_addressArray,
                DEFAULT_boolArray
                );
            if(hashCompareInternal(paramType,"string")){functionParamsValue.stringParamValue=stringParamValue;}
            if(hashCompareInternal(paramType,"uint")){functionParamsValue.uintParamValue=uintParamValue;}
            if(hashCompareInternal(paramType,"address")){functionParamsValue.addressParamValue=addressParamValue;}
            if(hashCompareInternal(paramType,"bool")){functionParamsValue.boolParamValue=boolParamValue;}
            
            if(hashCompareInternal(paramType,"stringArrray")){functionParamsValue.stringArrrayParamValue=stringArrrayParamValue;}
            if(hashCompareInternal(paramType,"uintArray")){functionParamsValue.uintArrayParamValue=uintArrayParamValue;}
            if(hashCompareInternal(paramType,"addressArray")){functionParamsValue.addressArrayParamValue=addressArrayParamValue;}
            if(hashCompareInternal(paramType,"boolArray")){functionParamsValue.boolArrayParamValue=boolArrayParamValue;}
            return functionParamsValue;
    }
    function PackageParamString(string memory stringParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("string",stringParamValue,DEFAULT_uint,DEFAULT_address,DEFAULT_bool,DEFAULT_stringArrray,DEFAULT_uintArray,DEFAULT_addressArray,DEFAULT_boolArray);
    }
    function PackageParamUint(uint256 uintParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("uint",DEFAULT_string,uintParamValue,DEFAULT_address,DEFAULT_bool,DEFAULT_stringArrray,DEFAULT_uintArray,DEFAULT_addressArray,DEFAULT_boolArray);
    }
    function PackageParamAddress(address addressParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("address",DEFAULT_string,DEFAULT_uint,addressParamValue,DEFAULT_bool,DEFAULT_stringArrray,DEFAULT_uintArray,DEFAULT_addressArray,DEFAULT_boolArray);
    }
    function PackageParamBool(bool boolParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("bool",DEFAULT_string,DEFAULT_uint,DEFAULT_address,boolParamValue,DEFAULT_stringArrray,DEFAULT_uintArray,DEFAULT_addressArray,DEFAULT_boolArray);
    }
    function PackageParamStringArray(string[] memory stringArrrayParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("stringArrray",DEFAULT_string,DEFAULT_uint,DEFAULT_address,DEFAULT_bool,stringArrrayParamValue,DEFAULT_uintArray,DEFAULT_addressArray,DEFAULT_boolArray);
    }
    function PackageParamUintArray(uint256[] memory uintArrayParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("uintArray",DEFAULT_string,DEFAULT_uint,DEFAULT_address,DEFAULT_bool,DEFAULT_stringArrray,uintArrayParamValue,DEFAULT_addressArray,DEFAULT_boolArray);
    }
    function PackageParamAddressArray(address[] memory addressArrayParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("addressArray",DEFAULT_string,DEFAULT_uint,DEFAULT_address,DEFAULT_bool,DEFAULT_stringArrray,DEFAULT_uintArray,addressArrayParamValue,DEFAULT_boolArray);
    }
    function PackageParamBoolArray(bool[] memory boolArrayParamValue) external returns(LDecoder.FunctionParamsValue memory){
        return PackageParam("boolArray",DEFAULT_string,DEFAULT_uint,DEFAULT_address,DEFAULT_bool,DEFAULT_stringArrray,DEFAULT_uintArray,DEFAULT_addressArray,boolArrayParamValue);
    }
    
}