// SPDX-License-Identifier: MIT
/// @title TxPreRouting -- TxPreRouting
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
pragma solidity ^0.8.0;
import {LTxDecoder} from "./LTxDecoder.sol";
import {ITxDecoder} from "./ITxDecoder.sol";
contract TxPreRouting{
    
    address DECODER_ADDRESS;
    function Initialize(address DecoderAddress) external{
        DECODER_ADDRESS=DecoderAddress;
    }
    
    function SetUint256Param(string memory _key,uint256 _value,address msgSender,uint256 msgValue,bytes4 msgSig) external{
        
        //=============================
        //package Process:
        //params(which save params info) and transaction(which save tx info)
        //=============================
        LTxDecoder.FunctionParamsValue memory _keyParam=ITxDecoder(DECODER_ADDRESS).PackageParamString(_key);
        LTxDecoder.FunctionParamsValue memory _valueParam=ITxDecoder(DECODER_ADDRESS).PackageParamUint(_value);
        ITxDecoder(DECODER_ADDRESS).setParam("_key",_keyParam);
        ITxDecoder(DECODER_ADDRESS).setParam("_value",_valueParam);
        ITxDecoder(DECODER_ADDRESS).addParamNameToArray("_key");
        ITxDecoder(DECODER_ADDRESS).addParamNameToArray("_value");
        
        // function setTransaction(address msgSender,address txOrigin,bytes4 msgSig,uint msgValue,string memory funName) external;
        string memory name="SetUint256Param(string,uint256)";
        ITxDecoder(DECODER_ADDRESS).setTransaction(msgSender,tx.origin,msgSig,msgValue,name);
        
        //=============================
        //active FireWallProcess:
        //=============================
    }
    
    


}
