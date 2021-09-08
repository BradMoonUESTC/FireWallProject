// SPDX-License-Identifier: MIT
/// @title Node -- Node
/// @author BloodMoon - <nerbonic@gmail.com>
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
contract Node{
    struct Node{
        bool look;
        bool isStart;
        bool isEnd;
        bool isNoGreed;
        bool isStre;
    }
    mapping(uint=>Node[]) nextNodes;

}