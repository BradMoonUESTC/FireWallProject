// SPDX-License-Identifier: MIT
/// @title RawAndRouter -- RawAndRouter
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
/// @BradMoonUESTC
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {LDecoder} from "./LDecoder.sol";
import {LRawAndRouter} from "./LRawAndRouter.sol";
import {IDecoder} from "./IDecoder.sol";
import {IRelayModule} from "./IRelayModule.sol";
import {IFilterProcess} from "./IFilterProcess.sol";
import {IPancakeFactory} from "./IPancakeFactory.sol";
import {IPancakePair} from "./IPancakePair.sol";
import {IPancakeERC20} from "./IPancakeERC20.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";
import "./SafeMath.sol";
contract DataCenter{
    using SafeMath for uint;

    //================Address================
    address PancakeFACTORY;
    
    mapping(string=>address) DEXAddress;
    mapping(string=>address) YieldAggregatorAddress;
    
    
    address OracleAddress;
    
    struct Price{
        uint timeStamp;
        uint priceInPool;
        uint priceInOracle;
    }
    struct PairToken{
        address pair;
        address tokenA;
        address tokenB;
    }
    mapping(string=>PairToken) PairAddress;
    mapping(string=>address) TokenAddress;
    mapping(string=>Price[]) Prices;
    
    //================Initializer================
    function Initialize(address _FACTORY) external{
        PancakeFACTORY=_FACTORY;
    }
    function getPriceInPool(address A,address B) external returns(uint){
        address pair=IPancakeFactory(PancakeFACTORY).getPair(A,B);
        uint price=IPancakeERC20(A).balanceOf(pair).div(IPancakeERC20(B).balanceOf(pair));
    }
    function recordPairPrice(Prices prices,string tokenPair) external{
        address A=TokenAddress(tokenA);
        address B=TokenAddress(tokenB);
        Price price=Price(block.timestamp,getPriceInPool(A,B))
        prices(string)
    }

}