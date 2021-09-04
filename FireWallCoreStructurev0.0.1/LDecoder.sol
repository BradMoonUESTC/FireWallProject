// SPDX-License-Identifier: MIT
/// @title LDecoder -- LDecoder
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

library LDecoder{

    //=====================struct======================
    struct Transaction {
        address msgSender;
        address txOrigin;
        bytes4 msgSig;
        uint msgValue;
        string funName;
    }
    struct FunctionParamsValue{
        string paramType;
        
        string stringParamValue;
        uint256 uintParamValue;
        address addressParamValue;
        bool boolParamValue;
        
        string[] stringArrrayParamValue;
        uint256[] uintArrayParamValue;
        address[] addressArrayParamValue;
        bool[] boolArrayParamValue;
    }
    
}