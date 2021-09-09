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
//          记录方式：SWAP+PATH[0]+PATH[length-1]
//         =================================================================
// }


contract DexStateMachine is StateMachine {
    //===========================状态初始化定义，后面也可以自己加（这里考虑用create2）===========================
    //对于dex中的币币兑换而言共有三步：1、计算能兑换的币；2、进行代币转账；3、进行swap函数处理；
    //在这里我们假设插桩只插在外围的router函数中，实际上也可以插在别的地方，插的桩越多状态就越多
    //所以3步-》4个状态每步有前后

    bytes32 public constant STATE_ONE = 'STATE_ONE';
    bytes32 public constant STATE_TWO = 'STATE_TWO';

    bytes32 public constant ROLE_ADMIN = 'ROLE_ADMIN';
    bytes32[] public _roles = [ROLE_ADMIN];

    //参数模板，自己加，
    address to;
    address pathFrom;
    address pathTo;
    uint amount;

    address toIN;
    address pathFromIN;
    address pathToIN;
    uint amountIN;

    //可以在构造函数里初始化，当然后期建议改成initilize函数，也可以用edit函数修改它们
    constructor(string memory param1, address param2, uint256 param3) public {
        setupStateMachine();
    }

    /**
    * @notice 修改一些参数
    */
    function edit(address From, address To, address sender,uint amountToSwap) public {
        to = sender;
        pathFrom = From;
        pathTo = To;
        amount=amountToSwap;
    }

    function transition(address sender,address From,address To,uint amountToSwap) public{
        toIN = sender;
        pathFromIN = From;
        pathToIN = To;
        amountIN=amountToSwap;
        if(getCurrentState()==STATE_ONE){transitionState(STATE_TWO);}
        if(getCurrentState()==STATE_TWO){transitionState(STATE_ONE);}
        
    }

    function testCallBack(bytes32 oldState,bytes32 currentState) public {
        //后件函数，在状态转换后，我们可以对状态机的参数进行一些修改，甚至是状态规则的修改
    }
    function testPreCondition(bytes32 fromState,bytes32 currentState) view public{
        //检测方式一：在状态转换前将传入参数与状态机当前参数进行比较（原始方式）
        if(toIN==to&&pathFromIN==pathTo&&pathFrom==pathToIN&&amount==amountIN){
            //有问题
        }
        //检测方式二：
        //前件函数


    }


    //===========================状态机初始化===========================
    function setupStateMachine() internal override {
        //生成状态
        createState(STATE_ONE);
        createState(STATE_TWO);

        // 为状态进行连接
        // STATE_PRE_GETAMOUNT=>STATE_BEFORE_TRANSFER
        addNextStateForState(STATE_ONE, STATE_TWO);
        addRoleForState(STATE_ONE, ROLE_ADMIN);

        // STATE_BEFORE_TRANSFER=>STATE_BEFORE_SWAP
        addNextStateForState(STATE_TWO, STATE_ONE);
        addRoleForState(STATE_TWO, ROLE_ADMIN);

        setInitialState(STATE_ONE);

        addPreConditionForState(STATE_ONE,testPreCondition);
        // addCallbackForState(STATE_AFTER_SWAP, testCallBack);
    }
}