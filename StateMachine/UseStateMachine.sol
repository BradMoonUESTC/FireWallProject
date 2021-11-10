// SPDX-License-Identifier: MIT
/// @title UseStateMachine -- UseStateMachine
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
/// @BradMoonUESTC
pragma solidity ^0.8.0;

import "./StateMachine.sol";


contract UseStateMachine is StateMachine {

    //===========================状态初始化定义，后面也可以自己加//（这里考虑用create2(不用看这句)）===========================
    bytes32 public constant STATE_ONE = 'STAGE_ONE_NAME';
    bytes32 public constant STATE_TWO = 'STAGE_TWO_NAME';
    bytes32 public constant STATE_THREE = 'STAGE_THREE_NAME';
    bytes32 public constant STATE_FOUR = 'STAGE_FOUR_NAME';
    bytes32 public constant STATE_FIVE = 'STAGE_FIVE_NAME';

    bytes32 public constant ROLE_ADMIN = 'ROLE_ADMIN';

    bytes32[] public _roles = [ROLE_ADMIN];

    //参数模板，自己加，可以在构造函数里初始化，当然后期建议改成initilize函数，也可以用edit函数修改它们
    string private _param1;
    address _param2;
    uint256 private _param3;
    //1110的一次测试提交
    constructor(string memory param1, address param2, uint256 param3) public {
        _param1 = param1;
        _param2 = param2;
        _param3 = param3;
        setupStateMachine();
    }

    /**
    * @notice 修改一些参数
    */
    function edit(string memory param1, address param2, uint256 param3) public {
        _param1 = param1;
        _param2 = param2;
        _param3 = param3;
    }
    address test3;
    uint test4;
    string test5;
    address testControll;
    address testControll2;
    function activateSTATETransition(address test,uint test1,string memory test2) public{
        test3=test;
        test4=test1;
        test5=test2;
        testControll=test;
        transitionState(STATE_TWO);
    }


    function testCallBack(bytes32 oldState,bytes32 currentState) public {
        testControll2=test3;
        test3=address(0);
        test4=0;
        test5="";
        //后置函数，在状态转换后，我们可以对状态机的参数进行一些修改，甚至是状态规则的修改

    }
    function testPreCondition(bytes32 fromState,bytes32 currentState) view public{
        //前置函数
    }


    //===========================状态机初始化===========================
    function setupStateMachine() internal override {
        //生成状态
        createState(STATE_ONE);
        createState(STATE_TWO);
        createState(STATE_THREE);
        createState(STATE_FOUR);
        

        // 为状态进行连接
        // STATE_ONE
        addNextStateForState(STATE_ONE, STATE_TWO);
        addRoleForState(STATE_ONE, ROLE_ADMIN);

        // STATE_TWO
        addNextStateForState(STATE_TWO, STATE_THREE);
        addRoleForState(STATE_TWO, ROLE_ADMIN);

        // STATE_THREE
        addNextStateForState(STATE_THREE, STATE_FOUR);
        addRoleForState(STATE_THREE, ROLE_ADMIN);

        // STATE_FOUR
        addNextStateForState(STATE_FOUR, STATE_FIVE);
        addRoleForState(STATE_FOUR, ROLE_ADMIN);

        setInitialState(STATE_ONE);

        //这里需要注意，我可以将函数作为参数传入进去
        //看这个链接：https://ethereum.stackexchange.com/questions/3342/pass-a-function-as-a-parameter-in-solidity
        //以及：https://docs.soliditylang.org/en/latest/types.html#function-types
        //其原理不难，其实就是在合约继承的情况下（也就是都在一个合约里）用函数keccak256之后的8位函数签名+参数来进行调用
        //****它会自行调用本地上下文运行环境中满足这个函数签名的函数

        //TODO: 这个特性已经是很久就有的特性，可以尝试用于防火墙主架构或者模块中
        //怎么用：直接把定义好的函数名（只有函数名）传进去即可，一定要满足bytes32，bytes32的形式（对应oldState和toState）
        addPreFunctionsForState(STATE_TWO,testPreCondition);
        addPostFunctionsForState(STATE_TWO, testCallBack);
    }

    /**
    * 一些解释：到这里状态机和基本的使用方式就ok了，但依然有很多TODO需要迭代
    * 另外，这个合约内虽然给了状态机使用的例子，但是最终如何在外部使用状态机，则需要将这个合约开放部分接口给外部，比如说：
    * 在交易所合约中我们开放这个合约的状态定义权给外面，那么我们可以定义交易所的不同状态，设置状态修改的权限
    * 同时，在状态更改时，我们要尝试定义状态更改的前提条件
    * （在外部合约中定义，比如说有人进行币币兑换时，我们在那里增加一句【对状态机的状态进行更改】（当然这里本身应该更明确的是使用rxJAVA中的flowable，以达成自动化更改状态，也就是控制反转的结果））
    * 同时，我们也可以增加一些针对于状态机特有参数的处理，这些处理就放在callback和precondition当中（这两个东西在StateMachine合约中有详细解释）
    * 用这种方式，我们可以将状态记录在StateMachine的history中，不过现在history中记录的数据并不全面，虽然已经有了前后状态但是。。。如果有数据也许会更好，这里可能需要进行状态扩展以及建模
    * 以上是解释以及一些问题

    * 第二个解释核问题：对于多个合约的状态，如果我们全部记录到一个状态机里会不会是好的？如果两个合约A,B的状态历史我需要A历史，B历史和A+B历史，那应该怎么记录？
    * 所以这里也许需要一个状态机聚合器
    */
}