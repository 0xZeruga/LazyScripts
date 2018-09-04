
pragma solidity ^0.4.24;

import "./SafeSol/Ownable.sol";
import "./Game.sol";

contract KeyValueStorage is Ownable {

    uint256 public totalSupply;

    mapping(address=>uint256)OwnedTokens;
    mapping(address=>Gladiator[]) OwnedGladiators;
    mapping(uint256=>mapping(string=>Item))ItemsOnGladiator;

    mapping(address => mapping(bytes32 => uint256)) _uintStorage;
    mapping(address => mapping(bytes32 => address)) _addressStorage;
    mapping(address => mapping(bytes32 => bool)) _boolStorage;

    mapping(address => mapping(bytes32 => Monster)) _monsterStorage;
    mapping(address => mapping(bytes32 => Gladiator)) _gladiatorStorage;
    mapping(address => mapping(bytes32 => Item)) _itemStorage;

    mapping(address=>uint256) public balanceOf;

    uint constant GLADIATOR_ID;
    uint public constant MIN_NUM = 1;
    uint public constant MAX_NUM = 100;

    constructor() {
        GLADIATOR_ID = 0;
    }

    /**** Get Methods ***********/

    function getAddress(bytes32 key) public view returns (address) {
        return _addressStorage[msg.sender][key];
    }

    function getUint(bytes32 key) public view returns (uint) {
        return _uintStorage[msg.sender][key];
    }

    function getBool(bytes32 key) public view returns (bool) {
        return _boolStorage[msg.sender][key];
    }

    function getMonster(bytes32 key) public view returns (Monster) {
        return _monsterStorage[msg.sender][key];
    }

    function getGladiator(bytes32 key) public view returns (Gladiator) {
        return _gladiatorStorage[msg.sender][key];
    }

    function getItem(bytes32 key) public view returns (Item) {
        return _itemStorage[msg.sender][key];
    }

    function getGladiatorID() public pure returns (uint256) {
        return GLADIATOR_ID;
    }
    
    function getTokens(address _a) public pure returns (uint256) {
        return _a.OwnedTokens;
    }

    function getTotalTokens() public pure returns (uint256) {
        return totalSupply;
    }

    /**** Set Methods ***********/

    function setAddress(bytes32 key, address value) public {
        _addressStorage[msg.sender][key] = value;
    }

    function setUint(bytes32 key, uint value) public {
        _uintStorage[msg.sender][key] = value;
    }

    function setBool(bytes32 key, bool value) public {
        _boolStorage[msg.sender][key] = value;
    }

    function setMonster(bytes32 key, Monster value) public {
        _monsterStorage[msg.sender][key] = value;
    }

    function setGladiator(bytes32 key, Gladiator value) public {
        _gladiatorStorage[msg.sender][key] = value;
    }

    function setItem(bytes32 key, Item value) public {
        _itemStorage[msg.sender][key] = value;
    }

    function setGladiatorID() private {
        GLADIATOR_ID += 1;
    }

    function setTokensForAddress(address _a, uint256 _mintedAmount) public {
        _a.OwnedTokens += _mintedAmount;
        totalSupply += _mintedAmount;
    } 

    function rand() private view returns (uint256){
        uint256 seedInt = uint256(seedHash)/2;
        seedInt += block.timestamp;
        return uint256(sha256(abi.encodePacked(seedInt)));
    }
}

