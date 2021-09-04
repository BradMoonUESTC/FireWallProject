// SPDX-License-Identifier: MIT
/// @title Module Manager - manages the contractFireWall Module
/// @author BloodMoon - <nerbonic@gmail.com>
pragma solidity ^0.6.12;

interface ITxFireWallProcess {
    //=====================struct======================
    struct Transaction {
        address msgSender;
        bytes msgData;
        uint Gas;
        address txOrigin;
        bytes4 msgSig;
        uint msgValue;
    }

    struct RawTable{
        Transaction tx;
        bool ifRaw;
    }

    struct RouteTable{
        Transaction tx;
        bool ifRoute;
    }
    struct RelayTable{
        Transaction Tx;
        bool ifRelay;
        //which module to relay
    }

    //=====================external======================
    function TxPreRouting(address msgSender,bytes memory msgData,uint Gas,address txOrigin,bytes4 msgSig,uint msgValue) external returns(Transaction tx);
    function TxRouteProcess(Transaction tx) external returns(bool ret);

    function modifyRawTable(address msgSender,bytes memory msgData,uint Gas,address txOrigin,bytes4 msgSig,uint msgValue,bool ifRaw) external returns(bool ret);
    function modifyRouteTable(address msgSender,bytes memory msgData,uint Gas,address txOrigin,bytes4 msgSig,uint msgValue,bool ifFilter) external returns(bool ret);
    function modifyRelayTable(address msgSender,bytes memory msgData,uint Gas,address txOrigin,bytes4 msgSig,uint msgValue,bool ifRelay) external returns(bool ret);

    //=====================internal======================
    function checkTxIfRaw(Transaction tx,RawTable rawTable) internal returns(bool ret);
    function checkTxIfFilter(Transaction tx,RouteTable routeTable) internal returns(bool ret);
    function checkTxIfRelay(Transaction tx,RelayTable relayTable) internal returns(bool ret);

    function decisionTxIfRelay(Transaction tx,,RelayTable relayTable) internal;
function decisionTxIfFilter(Transaction tx,,RouteTable routeTable) internal;

function executeRelay(Trnsaction tx) internal;
function executeFilter(Transaction tx) internal;

function _modifyRawTable(RawTable rawTable) internal returns(bool ret);
function _modifyRouteTable(RouteTable routeTable) internal returns(bool ret);
function _modifyRelayTable(RelayTable relayTable) internal returns(bool ret);

//=====================event======================


}
