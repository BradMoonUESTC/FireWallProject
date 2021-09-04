// SPDX-License-Identifier: MIT
/// @title ITxDecoder -- ITxDecoder
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LTxDecoder} from "./LTxDecoder.sol";
interface ITxDecoder{

    function PackageParamString(string memory stringParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    function PackageParamUint(uint256 uintParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    function PackageParamAddress(address addressParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    function PackageParamBool(bool boolParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    function PackageParamStringArray(string[] memory stringArrrayParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    function PackageParamUintArray(uint256[] memory uintArrayParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    function PackageParamAddressArray(address[] memory addressArrayParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    function PackageParamBoolArray(bool[] memory boolArrayParamValue) external returns(LTxDecoder.FunctionParamsValue memory);
    
    
    function setParam(string memory paramsName,LTxDecoder.FunctionParamsValue memory param) external;
    function getParam(string memory paramsName) external returns(LTxDecoder.FunctionParamsValue memory param);
    function setTransaction(address msgSender,address txOrigin,bytes4 msgSig,uint msgValue,string memory funName) external;
    function getTransaction() external returns(LTxDecoder.Transaction memory transaction);
    function addParamNameToArray(string memory newName) external;
    function getAllParamName() external returns(string[] memory);
}