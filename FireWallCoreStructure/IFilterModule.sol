// SPDX-License-Identifier: MIT
/// @title IFilterModule -- IFilterModule
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface IFilterModule{

    function activeFilterModule() external returns(bool);
    function activeDataAggregatorModule() external returns(bool);
    function activeRiskEstimateModule() external returns(bool);
}