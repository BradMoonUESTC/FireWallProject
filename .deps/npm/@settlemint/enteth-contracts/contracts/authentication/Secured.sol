// SPDX-License-Identifier: UNLICENSED
/**
 * Copyright (C) SettleMint NV - All Rights Reserved
 *
 * Use of this file is strictly prohibited without an active license agreement.
 * Distribution of this file, via any medium, is strictly prohibited.
 *
 * For license inquiries, contact hello@settlemint.com
 */

pragma solidity ^0.8.0;

import './GateKeeper.sol';
import '../utility/conversions/Converter.sol';

/**
 * @title Executes role-based permission checks
 */
contract Secured is Converter {
  GateKeeper public gateKeeper;

  modifier auth(bytes32 _role) {
    require(canPerform(msg.sender, _role), 'Sender does not have the correct role');
    _;
  }

  modifier authMany(bytes32[] memory _roles) {
    bool hasRole = false;
    for (uint256 i = 0; i < _roles.length; i++) {
      if (canPerform(msg.sender, _roles[i])) {
        hasRole = true;
        break;
      }
    }
    require(hasRole == true, 'Sender does not have the correct role');
    _;
  }

  modifier authWithCustomReason(bytes32 _role, string memory reason) {
    require(canPerform(msg.sender, _role), reason);
    _;
  }

  modifier authManyWithCustomReason(bytes32[] memory _roles, string memory reason) {
    bool hasRole = false;
    for (uint256 i = 0; i < _roles.length; i++) {
      if (canPerform(msg.sender, _roles[i])) {
        hasRole = true;
        break;
      }
    }
    require(hasRole == true, reason);
    _;
  }

  constructor(address _gateKeeper) {
    gateKeeper = GateKeeper(_gateKeeper);
  }

  /**
   * @notice Internal function to check if the address has the required role
   */
  function canPerform(address _sender, bytes32 _role) internal view returns (bool) {
    return address(gateKeeper) == address(0x0) || gateKeeper.hasPermission(_sender, address(this), _role);
  }
}
