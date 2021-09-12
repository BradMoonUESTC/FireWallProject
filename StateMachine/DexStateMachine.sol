// SPDX-License-Identifier: MIT
/// @title DexStateMachine -- DexStateMachine
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
/// @BradMoonUESTC
pragma solidity ^0.8.0;

import "./StateMachine.sol";


// function swapExactTokensForTokens(
//         uint amountIn,
//         uint amountOutMin,
//         address[] calldata path,
//         address to,
//         uint deadline
//     ) external override ensure(deadline) returns (uint[] memory amounts) {
        
//         amounts = PancakeLibrary.getAmountsOut(factory, amountIn, path);
//         require(amounts[amounts.length - 1] >= amountOutMin, 'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT');
//         TransferHelper.safeTransferFrom(path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]);
//         _swap(amounts, path, to);
//         =================================================================
//         ---->state记录（记录address to,记录path[0],path[length-1],记录amountIn）
//          记录方式：SWAP+PATH[0]+PATH[length-1]？///
//         =================================================================
// }


contract DexStateMachine is StateMachine {
    //===========================状态初始化定义，后面也可以自己加（这里考虑用create2）===========================
    //对于dex中的币币兑换而言共有三步：1、计算能兑换的币；2、进行代币转账；3、进行swap函数处理；
    //在这里我们假设插桩只插在外围的router函数中，实际上也可以插在别的地方，插的桩越多状态就越多

    struct DexData{
        address to;
        address fromToken;
        address toToken;
        uint amounts;
    }

    mapping(bytes32=>bytes32) PackedDataToState;//keccackParam=>state

    

    bytes32 public constant ROLE_ADMIN = 'ROLE_ADMIN';
    bytes32[] public _roles = [ROLE_ADMIN];

    //可以在构造函数里初始化，当然后期建议改成initilize函数，也可以用edit函数修改它们
    constructor() public {
        setupStateMachine();
    }

    function transition(address to,address fromToken,address toToken,uint amounts) public{
        bytes32 packedData=encodeData(to, fromToken, toToken, amounts);
        bytes32 packedDataReverse=encodeData(to, toToken, fromToken, amounts);
        //===========================状态转换===========================
        //====================转换规则：A=>B/A=>newB====================
        //如果状态不存在（尚未创建），则新建一个状态，并为当前状态添加一个新状态作为次态
        
        
        if(!states[packedData].ifCreated){
            createState(packedData);
            addNextStateForState(getCurrentState(), packedData);
        }
        // //如果状态存在，则将当前状态链接到次态（如果没有链接的话）
        if(states[packedData].ifCreated){
            //如果两个状态未连接
            if(!checkNextStates(getCurrentState(),packedData)){
                addNextStateForState(getCurrentState(),packedData);
            }
        }

        // //最后进行状态转换
        transitionState(packedData);

    }
    function encodeData(address to,address fromToken,address toToken,uint amounts) public pure returns(bytes32){
        return keccak256(abi.encodePacked(to,fromToken,toToken,amounts));
    }


    function testCallBack(bytes32 oldState,bytes32 currentState) public {
        //后件函数，在状态转换后，我们可以对状态机的参数进行一些修改，甚至是状态规则的修改
    }
    function testPreCondition(bytes32 fromState,bytes32 currentState) view public{
        //检测方式一：在状态转换前将传入参数与状态机当前参数进行比较（原始方式）
        
    }
    //===========================状态机初始化===========================
    function setupStateMachine() internal override {
        //生成状态
        // createState(STATE_ONE);
         createState(encodeData(address(0),address(0),address(0),1));

        // // 为状态进行连接
        // // STATE_PRE_GETAMOUNT=>STATE_BEFORE_TRANSFER
        // addNextStateForState(STATE_ONE, STATE_TWO);
        // addRoleForState(STATE_ONE, ROLE_ADMIN);

        // // STATE_BEFORE_TRANSFER=>STATE_BEFORE_SWAP
        // addNextStateForState(STATE_TWO, STATE_ONE);
        // addRoleForState(STATE_TWO, ROLE_ADMIN);

        setInitialState(encodeData(address(0),address(0),address(0),1));

        // addPreFunctionsForState(STATE_ONE,testPreCondition);
        // addPreFunctionsForState(STATE_TWO,testPreCondition);
        // addCallbackForState(STATE_AFTER_SWAP, testCallBack);
    }
}