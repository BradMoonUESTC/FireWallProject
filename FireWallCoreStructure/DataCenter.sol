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

    //================Project Address================
    address PancakeFACTORY;
    mapping(string=>address) OracleAddress;
    mapping(string=>address) DEXAddress;
    mapping(string=>address) YieldAggregatorAddress;
    
    
    
    //================Token Address================
    mapping(string=>address) TokenAddress;
    
    mapping(string=>address) PairAddress;
    
    //================Price=========================
    
    mapping(string=>Price[]) Prices;

    struct Price{
        uint timeStamp;
        uint priceInPool;
        uint priceInOracle;
    }
    
    //================Initializer================
    function Initialize(address _FACTORY) external{
        PancakeFACTORY=_FACTORY;
    }
    
    //================Op Price================
    function getPriceInPool(address A,address B) public returns(uint){
        
        address pair=IPancakeFactory(PancakeFACTORY).getPair(A,B);
        address token0=IPancakePair(pair).token0()==A?A:B;
        address token1=IPancakePair(pair).token0()==B?B:A;
        uint price=IPancakeERC20(token0).balanceOf(pair).mul(1e18).div(IPancakeERC20(token1).balanceOf(pair));
        return price;//real price*1e18
    }
    function getPriceInPool(address pairToken) public returns(uint){
        address A=IPancakePair(pairToken).token0();
        address B=IPancakePair(pairToken).token1();
        return getPriceInPool(A,B);
    }
    
    function getPriceInOracle(address oracleAddress) public returns(uint){
        AggregatorV3Interface PriceFeed = AggregatorV3Interface(oracleAddress);
        (,int256 priceInOracle, , ,)=PriceFeed.latestRoundData();
        return uint(priceInOracle)*1e28;
        //priceInOracle is real price/1e10,we need to make equal to priceInPool ,so mul 1e10 and mul 1e18(according to line 55)
    }
    
    function recordPairPrice(string memory tokenPair) public{
        //the tokenPair name such as BTC-ETH or ETH-BTC need to recheck
        //both data(include priceInOracle AND priceInPool)are all realPrice*1e18(in order to avoid float)
        
        //get oracle data
        uint priceInOracle=getPriceInOracle(OracleAddress[tokenPair]);
        
        //get pool data
        uint priceInPool=getPriceInPool(PairAddress[tokenPair]);
        
        Price memory price=Price(block.timestamp,priceInPool,priceInOracle);
        Prices[tokenPair].push(price);
    }
    
    //example of filter,consider move to module
    function checkPrice(string memory tokenPair,uint threshold) external returns(bool){
        
        uint priceInPool=getPriceInPool(PairAddress[tokenPair]);
        uint priceInOracle=getPriceInOracle(OracleAddress[tokenPair]);
        uint priceDifference=priceInPool>priceInOracle?priceInPool.sub(priceInOracle):priceInOracle.sub(priceInPool);
        if(priceDifference.div(priceInOracle)*100*1e18>threshold*1e18){
            //TODO: overflow the threshold
            return false;
        }
        return true;
        // recordPairPrice(tokenPair);
        // uint priceInPool=Prices[tokenPair][Prices[tokenPair].length-1].priceInPool;
        // int256 priceInOracle=Prices[tokenPair][Prices[tokenPair].length-1].priceInOracle;
        
    }
    
    //================modify mapping================
    function modifyOracleAddress(string memory tokenPair,address oracleAddress) external{
        OracleAddress[tokenPair]=oracleAddress;
    }
    function modifyTokenAddress(string memory token,address tokenAddress) external{
        TokenAddress[token]=tokenAddress;
    }
    function modifyPairAddress(string memory tokenPair,address tokenPairAddress) external{
        PairAddress[tokenPair]=tokenPairAddress;
    }
    

}