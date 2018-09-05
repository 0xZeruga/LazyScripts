
pragma solidity ^0.4.24;

import "./SafeSol/Ownable.sol";
import "./Game.sol";

/// @author Jacob Eriksson
contract KeyValueStorage is Ownable {

    constructor() public {
        id = 0;
        latestblock = block.number;
    }

    //Map _storage address to msg.sender address to data stored on that address.
    mapping(address=> mapping(address => uint256)) OwnedTokens;
    mapping(address=> mapping(address => uint256)) OwnedGladiators;

    mapping(uint256=>mapping(string=>uint256))ItemsOnGladiator;

    mapping(address => mapping(bytes32 => uint256)) _uintStorage;
    mapping(address => mapping(bytes32 => address)) _addressStorage;
    mapping(address => mapping(bytes32 => bool)) _boolStorage;
    mapping(address => mapping(bytes32 => string)) _stringStorage;

    mapping(address => mapping(bytes32  => Monster)) _monsterStorage;
    mapping(address => mapping(bytes32 => Gladiator)) _gladiatorStorage;
    mapping(address => mapping(bytes32 => Item)) _itemStorage;

    uint constant GLADIATOR_ID;
    uint public constant MIN_NUM = 1;
    uint public constant MAX_NUM = 100;

    uint256 public totalSupply;
    uint256 public latestblock;
    uint public price;
    token public tokenReward;

    bytes32 private seedHash;

    constructor() {
        GLADIATOR_ID = 0;
    }

    /**** Modifiers */
    modifier IsAlive(Gladiator _g) {
        require(_g.currentHealth > 0, "Health is less than 0");
        _;
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
        value.owner.OwnedGladiators[value.id] = value;
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

    ///ENUMS
    enum GladiatorState {
        PRACTICE, 
        FMONSTER,
        FPLAYER,
        IDLE
    }

    ///STRUCTS

    struct Gladiator {

        address owner;
        string name;

        uint256 strength;
        uint256 toughness;
        uint256 dexterity;
        uint256 maxHealth;
        uint256 currentHealth;
        uint256 damage;
        uint256 dodgeChance;
        uint256 critChance;
        
        uint256 level;
        uint256 experience;
        uint256 unspentAttributePoints;
    
        uint256 age; //Current Block minus birth.
        uint256 birth;
        uint256 id;

        uint256 killedGladiators;
        uint256 killedMonsters;

        GladiatorState state;

        mapping (uint => Item) items;
    }

    struct Monster  {
        string name;
        string description;
        string levelspan;
        uint256 health;
        uint256 damage;
        uint256 crit;
        uint256 dodge;
    }

    struct Item {
        string name;
        string slot;
        string description;
            
        uint256 strength_bonus;
        uint256 toughness_bonus;
        uint256 dexterity_bonus;

        uint256 health_bonus;
        uint256 damage_bonus;
        uint256 dodge_bonus;
        uint256 crit_bonus;

        uint256 duration;
    }

    //**** EVENTS  */
    event gladiatorinfo(

        string name,
        address gladiatorowner,

        uint256 strength,
        uint256 toughness,
        uint256 dexterity,
        uint256 health,
        uint256 currentHealth,
        uint256 damage,
        uint256 dodgeChance,
        uint256 critChance,
        
        uint256 level,
        uint256 experience,
        uint256 unspentAttributePoints,
    
        uint256 birth,
        uint256 id,

        mapping(uint => item),

        GladiatorState state
    );

    event MonsterInfo(
        string name,
        string description,
        string levelspan,
        uint256 health,
        uint256 damage,
        uint256 crit,
        uint256 dodge  
    );

    event ItemInfo(
        string name,
        string description,
        string levelspan,
        uint256 health,
        uint256 damage,
        uint256 crit,
        uint256 dodge  
    );

    event damageinfo(
        //Ex. A hit B with WeaponName for X damage
        string attackerName,
        string defenderName,
        string weaponName,
        uint256 damage

    );
    event critinfo(
        //Ex. A critically hit B with WeaponName for X damage
        string attackerName,
        string defenderName,
        string weaponName,
        uint256 damage

    );
    event dodgeinfo(
        //Ex. A attacked B, but B dodged it swiftly.
        string attackerName,
        string defenderName
    );

    event deadgladiator(
        string killed,
        string killer,
        uint256 blocknr
    );

    event healing(
        string typeofhealing,
        uint256 amount,
        Gladiator gladiator
    );

}

