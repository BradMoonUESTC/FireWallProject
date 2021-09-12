// SPDX-License-Identifier: MIT
/// @title StateMachine -- StateMachine
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.0.1
/// @BradMoonUESTC
pragma solidity ^0.8.0;

abstract contract StateMachine {

  //===========================定义===========================
  
  //输出状态转换日志
  event Transition(address sender, bytes32 fromState, bytes32 toState);

  /**
   * 之所以要用bytes32作为状态的大部分表示方法有两个考虑：1、用string方式会涉及到许多复杂的类型转换，消耗gas；2、用uint方式没有办法表达过多信息
   * 状态详细信息的数据结构
   *
   * 关于preFunctions，postFunctions：
   * preCondition就是前件处理函数，也就是前置状态校验，是用于基于当前状态的数据，检查是否满足目标状态的要求，用preCondition这样的函数来依次检查
   * postFunctions就是后件处理函数，是在状态转换【后】要执行的一些必要性函数，比如数据重置等等
   *
   * 关于preFunction：TODO
   * preFunction暂时不用，它的作用类似于postFunctions，不同的是preFunction考虑是在状态转换【前】对状态进行整理
   */
  struct State {
    // 状态是否被创建
    bool ifCreated;

    // 已注册的函数
    mapping(bytes4 => bool) registedFunctions;

    // 当前状态涉及到的角色
    bytes32[] registedRoles;

    // 前置函数（条件）
    /**
     * @param bytes32 fromState
     * @param bytes32 toState
     */
    
    function(bytes32, bytes32) internal view[] preFunctions;

    // 后置函数
    /**
     * @param bytes32 fromState
     * @param bytes32 toState
     */
    function(bytes32, bytes32) internal[] postFunctions;

    // 前置条件满足后要进行的操作（动作），不一定要到次态
    // 动作函数,感觉没啥用，TODO
    /**
     * @param bytes32 fromState
     * @param bytes32 toState
     */
    function(bytes32, bytes32) internal[] actionFunctions;

    // 接下来可以进行转换的状态
    bytes32[] nextStates;
  }

  // 历史状态数据
  struct StateTransition {
    bytes32 fromState;//源状态
    bytes32 toState;//目标状态
    address transitor;//谁来进行的状态转换
    uint256 timestamp;//转换时间（block.timestamp)
    uint256 blockNum;//区块高度（block.number)
    address transitorOrigin;//交易发起者，可能与transitor不同
  }

  // 保存历史状态数据的列表
  StateTransition[] public history;

  mapping(bytes32 => State) internal states;

  //当前状态机所有已注册状态
  bytes32[] internal registedStates;

  //状态机的当前状态
  bytes32 internal currentState;

  // 函数选择器注册表
  bytes4[] internal knownSelectors;
  mapping(bytes4 => bool) internal knownSelector;


  //===========================函数修饰器——一些必要性检查===========================

  /**
   * @notice 检查状态是否被初始化
   */
  modifier checkStateMachineSetup {
    require(registedStates.length > 0, 'the state machine has not been setup');
    _;
  }

  /**
   * @notice 检查当前函数是否允许在状态中执行
   */
  modifier checkAllowedFunction {
    require(states[currentState].registedFunctions[msg.sig], 'the function is not allowed run in this currentState');
    _;
  }

  /**
   * @notice 检查两个状态间是否可以转换
   */
  modifier checkTransitionIfLegal(bytes32 toState) {
    checkTransitionIfLegalByCurrentState(getCurrentState(), toState);
    _;
  }

  /**
   * @notice 检查状态是否存在
   */
  modifier doesStateExist(bytes32 state) {
    require(states[state].ifCreated, 'this state is not created');
    _;
  }


  //===========================状态机数据查询===========================

  /**
   * @notice 查询历史状态
   */
  function getHistoryLength() public view returns (uint256) {
    return history.length;
  }

  /**
   * @notice 通过index返回某个历史状态
   * @dev 注意数组上界
   */
  function getHistory(uint256 index) public view
    returns (
      bytes32 fromState,
      bytes32 toState,
      address transitor,
      uint256 timestamp,
      uint256 blockNum,
      address transitorOrigin
    )
  {

    return (history[index].fromState, history[index].toState, history[index].transitor, history[index].timestamp,history[index].blockNum,history[index].transitorOrigin);
  }

  /**
   * @notice 返回当前状态
   */
  function getCurrentState() public view returns (bytes32 state) {
    return currentState;
  }

  /**
   * @notice 查询当前状态机的所有已注册状态
   */
  function getAllStates() public view returns (bytes32[] memory allStates) {
    return registedStates;
  }

  /**
   * @notice 查询状态机当前状态的所有的下一个可转换的状态
   */
  function getNextStates() public view returns (bytes32[] memory nextStates) {
    return states[currentState].nextStates;
  }

  /**
   * @notice 查询状态详情
   */
  function getState(bytes32 state) public view
    returns (
      bytes32 name,
      bytes32[] memory nextStates,
      bytes32[] memory registedRoles,
      bytes4[] memory registedFunctions
    )
  {
    State storage s = states[state];

    uint8 counter = 0;
    bytes4[] memory tmp = new bytes4[](knownSelectors.length);
    for (uint256 i = 0; i < knownSelectors.length; i++) {
      if (states[state].registedFunctions[knownSelectors[i]]) {
        tmp[counter] = knownSelectors[i];
        counter += 1;
      }
    }

    bytes4[] memory selectors = new bytes4[](counter);
    for (uint256 j = 0; j < counter; j++) {
      selectors[j] = tmp[j];
    }

    return (state, s.nextStates, s.registedRoles, selectors);
  }

  //===========================状态转换===========================

  /**
   * @notice 执行状态转换，并执行所有后置函数，并发射事件到日志
   * @param toState 目标状态
   */
  function transitionState(bytes32 toState) public checkStateMachineSetup() checkTransitionIfLegal(toState) {
    bytes32 oldState = currentState;
    currentState = toState;

    function(bytes32, bytes32) internal[] storage postFunctions = states[toState].postFunctions;
    // TODO
    for (uint256 i = 0; i < postFunctions.length; i++) {
      postFunctions[i](oldState, toState);
    }

    //历史状态更新
    history.push(
      StateTransition({ 
        fromState: oldState, 
        toState: toState, 
        transitor: msg.sender, 
        timestamp: block.timestamp,
        blockNum:block.number,
        transitorOrigin:tx.origin 
        })
    );

    //发射事件
    emit Transition(msg.sender, oldState, currentState);
  }


  //===========================状态机数据操作===========================

  /**
   * @dev 新增状态
   */
  function createState(bytes32 stateName) internal {
    require(!states[stateName].ifCreated, 'this state has already been created');
    states[stateName].ifCreated = true;
    registedStates.push(stateName);
  }

  /**
   * @dev 为状态增加可用的角色
   */
  function addRoleForState(bytes32 state, bytes32 role) internal doesStateExist(state) {
    states[state].registedRoles.push(role);
  }

  /**
   * @dev 为状态增加可执行的函数（注意函数签名bytes4，在实现里用keccak256加密别忘了）
   */
  function addAllowedFunctionForState(bytes32 state, bytes4 allowedFunction) internal doesStateExist(state) {
    if (!knownSelector[allowedFunction]) {
      knownSelector[allowedFunction] = true;
      knownSelectors.push(allowedFunction);
    }
    states[state].registedFunctions[allowedFunction] = true;
  }

  /**
   * @dev 为状态增加可用的目标状态
   */
  function addNextStateForState(bytes32 state, bytes32 nextState) internal doesStateExist(state) doesStateExist(nextState) {
    states[state].nextStates.push(nextState);
  }

  /**
   * @dev 为状态增加可用的后置函数
   */
  function addPostFunctionsForState(bytes32 state, function(bytes32, bytes32) internal postFunction) internal doesStateExist(state) {
    states[state].postFunctions.push(postFunction);
  }

    /**
   * @dev 为状态增加可用的前置函数
   */
  function addPreFunctionsForState(bytes32 state, function(bytes32, bytes32) internal view preFunction) internal doesStateExist(state) {
    states[state].preFunctions.push(preFunction);
  }

  /**
   * @dev 为状态增加可用的动作函数
   */
  function setActionFunctionForState(bytes32 state, function(bytes32, bytes32) internal actionFunction) internal doesStateExist(state) {
    states[state].actionFunctions.push(actionFunction);
  }
  
  /**
   * @dev 移除可用的前置函数
   */  
  function removePreFunctionForStateByIndex(bytes32 state,uint index) internal doesStateExist(state) returns (function(bytes32, bytes32) internal view[] memory){
    function(bytes32, bytes32) internal view[] storage functions = states[state].preFunctions;
      if(index >= functions.length) return functions;
      for(uint i = index; i<functions.length-1;i++) {
        functions[i]=functions[i+1];
      }
      delete functions[functions.length-1];
      return functions;
  }

    /**
   * @dev 移除可用的后置函数
   */  
  function removePostFunctionForStateByIndex(bytes32 state,uint index) internal doesStateExist(state) returns (function(bytes32, bytes32) internal[] memory){
    function(bytes32, bytes32) internal [] storage functions = states[state].postFunctions;
      if(index >= functions.length) return functions;
      for(uint i = index; i<functions.length-1;i++) {
        functions[i]=functions[i+1];
      }
      delete functions[functions.length-1];
      return functions;
  }

  /**
   * @notice 为状态机设置初始状态
   */
  function setInitialState(bytes32 initialState) internal {
    require(states[initialState].ifCreated, '');
    require(currentState == 0, '');
    currentState = initialState;
  }

  //===========================状态机的状态转换检查===========================

  /**
   * @notice 检查两个状态的转换合法性
   * @dev 状态是否存在？
   * @dev 两个状态是否可以转换？
   * @dev 状态转换权是否满足（角色）？
   * @dev 状态前置函数是否满足？
   */
  function checkTransitionIfLegalByCurrentState(bytes32 fromState, bytes32 toState) private view {
    require(states[fromState].ifCreated, 'from state not been created');
    require(states[toState].ifCreated, 'to state not been created');
    require(checkNextStates(fromState, toState), 'from state is not linked to to state');
    require(checkRegistedRoles(toState), 'cureent role has no right to transition state'); 
    checkPreFunctions(fromState, toState);//检查前置函数，具体操作由自定义的前置函数来决定
  }

  /**
   * @notice 检查两个状态是否可以转换
   */
  function checkNextStates(bytes32 fromState, bytes32 toState) internal view returns (bool hasNextState) {
    hasNextState = false;
    bytes32[] storage nextStates = states[fromState].nextStates;
    //TODO:这里需要遍历，考虑优化
    for (uint256 i = 0; i < nextStates.length; i++) {
      if (keccak256(abi.encodePacked(nextStates[i])) == keccak256(abi.encodePacked(toState))) {
        hasNextState = true;
        break;
      }
    }
  }

  /**
   * @notice 检查状态前提条件是否满足，这里用函数的形式检查
   */
  function checkPreFunctions(bytes32 fromState, bytes32 toState) private view {
    function(bytes32, bytes32) internal view[] storage preFunctions = states[toState].preFunctions;
    for (uint256 i = 0; i < preFunctions.length; i++) {
      preFunctions[i](fromState, toState);
    }
  }

  /**
   * @notice 检查状态前提条件是否满足，这里用函数的形式检查，检查通过后执行动作函数（不一定要到次态）
   * @dev 这个好像没啥用，留着
   */
  function checkPreFunctionsAndAction(bytes32 fromState, bytes32 toState) private {
    function(bytes32, bytes32) internal view[] storage preFunctions = states[toState].preFunctions;
    for (uint256 i = 0; i < preFunctions.length; i++) {
      preFunctions[i](fromState, toState);
    }
    function(bytes32, bytes32) internal [] storage actionFunctions = states[toState].actionFunctions;
    for (uint256 i = 0; i < actionFunctions.length; i++) {
      actionFunctions[i](fromState, toState);
    }
  }

  
  /**
   * @notice TODO:这里先不对角色进行限制，后面要改
   */
  function checkRegistedRoles(bytes32 toState) private view returns (bool isAllowed) {
    isAllowed = false;
    bytes32[] storage registedRoles = states[toState].registedRoles;
    if (registedRoles.length == 0) {
      isAllowed = true;
    }
  }

  /**
   * @notice 外部实现-状态机初始化，外部自定义
   */
  function setupStateMachine() internal virtual;
}
