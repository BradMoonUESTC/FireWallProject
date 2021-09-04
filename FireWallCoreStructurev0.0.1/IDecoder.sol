// SPDX-License-Identifier: MIT
/// @title IDecoder -- IDecoder
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LDecoder} from "./LDecoder.sol";
interface IDecoder{

    function PackageParamString(string memory stringParamValue) external returns(LDecoder.FunctionParamsValue memory);
    function PackageParamUint(uint256 uintParamValue) external returns(LDecoder.FunctionParamsValue memory);
    function PackageParamAddress(address addressParamValue) external returns(LDecoder.FunctionParamsValue memory);
    function PackageParamBool(bool boolParamValue) external returns(LDecoder.FunctionParamsValue memory);
    function PackageParamStringArray(string[] memory stringArrrayParamValue) external returns(LDecoder.FunctionParamsValue memory);
    function PackageParamUintArray(uint256[] memory uintArrayParamValue) external returns(LDecoder.FunctionParamsValue memory);
    function PackageParamAddressArray(address[] memory addressArrayParamValue) external returns(LDecoder.FunctionParamsValue memory);
    function PackageParamBoolArray(bool[] memory boolArrayParamValue) external returns(LDecoder.FunctionParamsValue memory);
    
    
    function setParam(string memory paramsName,LDecoder.FunctionParamsValue memory param) external;
    function getParam(string memory paramsName) external returns(LDecoder.FunctionParamsValue memory param);
    function setTransaction(address msgSender,address txOrigin,bytes4 msgSig,uint msgValue,string memory funName) external;
    function getTransaction() external returns(LDecoder.Transaction memory transaction);
    function addParamNameToArray(string memory newName) external;
    function getAllParamName() external returns(string[] memory);
}