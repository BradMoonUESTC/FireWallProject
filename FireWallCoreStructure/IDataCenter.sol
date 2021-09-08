// SPDX-License-Identifier: MIT
/// @title RawAndRouter -- RawAndRouter
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
/// @BradMoonUESTC
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
interface IDataCenter{
    
    //================Op Price================
    function getPriceInPool(address A,address B) external returns(uint);
    function getPriceInPool(address pairToken) external returns(uint);
    
    function getPriceInOracle(address oracleAddress) external returns(uint);
    
    function recordPairPrice(string memory tokenPair) external;
    
    function checkPrice(string memory tokenPair) external;
    

}