// SPDX-License-Identifier: MIT
/// @title PreRouting -- PreRouting
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
import {LDecoder} from "./LDecoder.sol";
import {IDecoder} from "./IDecoder.sol";
import {IRawAndRouter} from "./IRawAndRouter.sol";
contract PreRouting{
    
    address DECODER_ADDRESS;
    address RAWANDROUTER_ADDRESS;
    function Initialize(address DecoderAddress,address RawAndRouterAddress) external{
        DECODER_ADDRESS=DecoderAddress;
        RAWANDROUTER_ADDRESS=RawAndRouterAddress;
    }
    
    //=====================event======================
	//TODO: add event list
    
    function SetUint256Param(string memory _key,uint256 _value,address msgSender,uint256 msgValue,bytes4 msgSig) external returns(bool){
        
        //=============================
        //package Process:
        //params(which save params info) and transaction(which save tx info)
        //=============================
        LDecoder.FunctionParamsValue memory _keyParam=IDecoder(DECODER_ADDRESS).PackageParamString(_key);
        LDecoder.FunctionParamsValue memory _valueParam=IDecoder(DECODER_ADDRESS).PackageParamUint(_value);
        IDecoder(DECODER_ADDRESS).setParam("_key",_keyParam);
        IDecoder(DECODER_ADDRESS).setParam("_value",_valueParam);
        IDecoder(DECODER_ADDRESS).addParamNameToArray("_key");
        IDecoder(DECODER_ADDRESS).addParamNameToArray("_value");
        
        //=============================
        //active FireWallProcess:
        //=============================
        // function setTransaction(address msgSender,address txOrigin,bytes4 msgSig,uint msgValue,string memory funName) external;
        string memory name="SetUint256Param(string,uint256)";
        IDecoder(DECODER_ADDRESS).setTransaction(msgSender,tx.origin,msgSig,msgValue,name);
        return IRawAndRouter(RAWANDROUTER_ADDRESS).activeFireWall();
    }
    
    


}
