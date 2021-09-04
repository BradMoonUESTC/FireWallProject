// SPDX-License-Identifier: MIT
/// @title IFilterProcess -- IFilterProcess
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface IFilterProcess{

    function activeFilterProcess() external returns(bool,string memory,string memory);
}