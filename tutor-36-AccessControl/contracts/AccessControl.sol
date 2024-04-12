// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IAccessControl.sol";

abstract contract AccessControl is IAccessControl{

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 _role) {
        _checkRole(_role);
        _;
    }

    event RoleGrantedEvent(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
);

event RoleRevokedEvent(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
);

    event RoleAdminChangedEvent(
        bytes32 indexed role,
         bytes32 indexed previouseAdminRole,
          bytes32 indexed newAdminRole);

    function hasRole(bytes32 role, address account) public view virtual returns(bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, msg.sender);
    }
    function _checkRole(bytes32 role, address account) internal view virtual {
        if(!hasRole(role, account)) revert("no such role");
    }
    function getRoleAdmin(bytes32 role) public view returns(bytes32){
          return _roles[role].adminRole;
    }
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }
    
    //need control super admin should not renounce
    function renounceRole(bytes32 role, address account) public virtual  {
        require(account == msg.sender, "Can only renounce for self");
        //if role count (DEFAULT_ADMIN) < 2 ... reject operation...
        _revokeRole(role, account);
    }


    function setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 prevAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;

        emit RoleAdminChangedEvent(role, prevAdminRole, adminRole);
    }

     function _grantRole(bytes32 role, address account) internal virtual  {
        if(!hasRole(role, account)) {
        _roles[role].members[account] = true;

        emit RoleGrantedEvent (role, account, msg.sender);
        }


    }

     function _revokeRole(bytes32 role, address account) internal virtual  {
        if(hasRole(role, account)) {
        _roles[role].members[account] = false;
        }

        emit RoleRevokedEvent(role, account,  msg.sender);
    }
}