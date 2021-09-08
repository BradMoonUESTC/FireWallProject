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

    function getOracleAddress(string memory tokenPair) view external returns(address);
    function getTokenAddress(string memory token) view external returns(address);
    function getPairAddress(string memory tokenPair) view external returns(address);
    function getAggregatorAddress(string memory aggregatorName) view external returns(address);
    function getDecoderAddress() view external returns(address);

    function checkPrice(string memory tokenPair,uint threshold) external returns(bool);
}