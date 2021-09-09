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
   * 关于preConditions，callbacks：
   * preCondition是用于基于当前状态的数据，检查是否满足目标状态的要求，用preCondition这样的函数来依次检查
   * callbacks是在状态转换【后】要执行的一些必要性函数，比如数据重置等等
   *
   * 关于preFunction：TODO
   * preFunction暂时不用，它的作用类似于callbacks，不同的是preFunction考虑是在状态转换【前】对状态进行整理
   */
  struct State {
    // 状态是否被创建
    bool ifCreated;

    // 当前状态可以执行的所有函数
    mapping(bytes4 => bool) allowedFunctions;

    // 当前状态涉及到的角色
    bytes32[] allowedRoles;

    // 当前状态的前提验证函数
    function(bytes32, bytes32) internal view[] preConditions;

    // 在状态转换完成前要执行的函数
    function(bytes32, bytes32) internal[] callbacks;

    // 接下来可以进行转换的状态
    bytes32[] nextStates;

    // 状态转换前执行的逻辑函数
    bytes4 preFunction;
  }

  // 历史状态数据
  struct StateTransition {
    bytes32 fromState;//源状态
    bytes32 toState;//目标状态
    address transitor;//谁来进行的状态转换
    uint256 timestamp;//转换时间（block.timestamp)
  }

  // 保存历史状态数据的列表
  StateTransition[] public history;

  mapping(bytes32 => State) internal states;

  //当前状态机所有已注册状态
  bytes32[] internal possibleStates;

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
    require(possibleStates.length > 0, 'this statemachine has not been setup yet');
    _;
  }

  /**
   * @notice 检查当前函数是否允许在状态中执行
   */
  modifier checkAllowedFunction {
    require(states[currentState].allowedFunctions[msg.sig], 'this function is not allowed in this state');
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
    require(states[state].ifCreated, 'the state has not been created yet');
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
      uint256 timestamp
    )
  {
    // require(index >= 0 && index < history.length, 'Index out of bounds');//TODO: 考虑不增加这个断言，感觉没啥用
    return (history[index].fromState, history[index].toState, history[index].transitor, history[index].timestamp);
  }

  /**
   * @notice 返回当前状态
   */
  function getCurrentState() public view returns (bytes32 state) {
    //require(states[currentState].ifCreated, 'the initial state has not been created yet');//TODO: 考虑不增加这个断言，感觉没啥用
    return currentState;
  }

  /**
   * @notice 查询当前状态机的所有已注册状态
   */
  function getAllStates() public view returns (bytes32[] memory allStates) {
    return possibleStates;
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
      bytes32[] memory allowedRoles,
      bytes4[] memory allowedFunctions,
      bytes4 preFunction
    )
  {
    State storage s = states[state];

    uint8 counter = 0;
    bytes4[] memory tmp = new bytes4[](knownSelectors.length);
    for (uint256 i = 0; i < knownSelectors.length; i++) {
      if (states[state].allowedFunctions[knownSelectors[i]]) {
        tmp[counter] = knownSelectors[i];
        counter += 1;
      }
    }

    bytes4[] memory selectors = new bytes4[](counter);
    for (uint256 j = 0; j < counter; j++) {
      selectors[j] = tmp[j];
    }

    return (state, s.nextStates, s.allowedRoles, selectors, s.preFunction);
  }

  //===========================状态转换===========================

  /**
   * @notice 执行状态转换，并执行所有在转换【后】要执行的函数（包括数据重置等自定义的函数），并发射事件到日志
   * @param toState 目标状态
   */
  function transitionState(bytes32 toState) public checkStateMachineSetup() checkTransitionIfLegal(toState) {
    bytes32 oldState = currentState;
    currentState = toState;

    function(bytes32, bytes32) internal[] storage callbacks = states[toState].callbacks;
    // TODO:！！！！！重新考虑下这种调用方法
    for (uint256 i = 0; i < callbacks.length; i++) {
      callbacks[i](oldState, toState);
    }

    //历史状态更新
    history.push(
      StateTransition({ fromState: oldState, toState: toState, transitor: msg.sender, timestamp: block.timestamp })
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
    possibleStates.push(stateName);
  }

  /**
   * @dev 为状态增加可用的角色
   */
  function addRoleForState(bytes32 state, bytes32 role) internal doesStateExist(state) {
    states[state].allowedRoles.push(role);
  }

  /**
   * @dev 为状态增加可执行的函数（注意函数签名bytes4，在实现里用keccak256加密别忘了）
   */
  function addAllowedFunctionForState(bytes32 state, bytes4 allowedFunction) internal doesStateExist(state) {
    if (!knownSelector[allowedFunction]) {
      knownSelector[allowedFunction] = true;
      knownSelectors.push(allowedFunction);
    }
    states[state].allowedFunctions[allowedFunction] = true;
  }

  /**
   * @dev 为状态增加可用的目标状态
   */
  function addNextStateForState(bytes32 state, bytes32 nextState) internal doesStateExist(state) doesStateExist(nextState) {
    states[state].nextStates.push(nextState);
  }

  /**
   * @dev 为状态增加可用的回调函数
   */
  function addCallbackForState(bytes32 state, function(bytes32, bytes32) internal callback) internal doesStateExist(state) {
    states[state].callbacks.push(callback);
  }

  function addPreConditionForState(bytes32 state, function(bytes32, bytes32) internal view preCondition)
    internal
    doesStateExist(state)
  {
    states[state].preConditions.push(preCondition);
  }

  function setPreFunctionForState(bytes32 state, bytes4 functionSig) internal doesStateExist(state) {
    states[state].preFunction = functionSig;
  }

  /**
   * @notice 为状态机设置初始状态
   */
  function setInitialState(bytes32 initialState) internal {
    require(states[initialState].ifCreated, 'the initial state has not been created yet');
    require(
      currentState == 0,
      'the current state has already been set, so you cannot configure the initial state and override it'
    );
    currentState = initialState;
  }

  //===========================状态机的状态转换检查===========================

  /**
   * @notice 检查两个状态的转换合法性
   * @dev 状态是否存在？
   * @dev 两个状态是否可以转换？
   * @dev 状态转换权是否满足（角色）？
   * @dev 状态前提条件是否满足？
   */
  function checkTransitionIfLegalByCurrentState(bytes32 fromState, bytes32 toState) private view {
    require(states[fromState].ifCreated, 'the from state has not been configured in this object');
    require(states[toState].ifCreated, 'the to state has not been configured in this object');
    require(checkNextStates(fromState, toState), 'the requested next state is not an allowed next state for this transition');
    require(checkAllowedRoles(toState), 'the sender of this transaction does not have a role that allows transition between the from and to states'); 
    checkPreConditions(fromState, toState);//检查前提条件，不对就回滚 TODO:这里考虑改成返回bool来控制，前提条件不要太严格？
  }

  /**
   * @notice 检查两个状态是否可以转换
   */
  function checkNextStates(bytes32 fromState, bytes32 toState) private view returns (bool hasNextState) {
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
  function checkPreConditions(bytes32 fromState, bytes32 toState) private view {
    function(bytes32, bytes32) internal view[] storage preConditions = states[toState].preConditions;
    for (uint256 i = 0; i < preConditions.length; i++) {
      preConditions[i](fromState, toState);
    }
  }


  
  /**
   * @notice TODO:这里先不对角色进行限制，后面要改
   */
  function checkAllowedRoles(bytes32 toState) private view returns (bool isAllowed) {
    isAllowed = false;
    bytes32[] storage allowedRoles = states[toState].allowedRoles;
    if (allowedRoles.length == 0) {
      isAllowed = true;
    }
    // for (uint256 i = 0; i < allowedRoles.length; i++) {
    //   if (canPerform(msg.sender, allowedRoles[i])) {
    //     isAllowed = true;
    //     break;
    //   }
    // }
  }

  /**
   * @notice 状态机初始化，外部自定义
   */
  function setupStateMachine() internal virtual;
}
