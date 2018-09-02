

pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./Game.sol";
import "./Equipment.sol";
import "./Monster.sol";

contract Game {
    
    constructor() public {
        id = 0;
        latestblock = block.number;
    }
    
    //Called once Ether is sent to the account.
    function () public payable {
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.mintToken(msg.sender, amount/price);
        emit FundTransfer(msg.sender, amount, true);
    }

    mapping(address=>Gladiator[])OwnedGladiators;
    mapping(uint=>Gladiator)Gladiators;

    bytes32 private seedHash;
    
    uint256 public id;
    uint256 public latestblock;

    uint public constant MIN_NUM = 1;
    uint public constant MAX_NUM = 100;

    uint public amountRaised;
    address public beneficiary;

    uint public price;
    token public tokenReward;

    event FundTransfer(address backer, uint amount, bool isContribution);
    

    //TODO Check state before pracatice, fmonster, fplayer to ensure it's idle.
    enum GladiatorState {
        PRACTICE, 
        FMONSTER,
        FPLAYER,
        IDLE
    }
    
    struct Gladiator {

        address Owner;

        string Name;

        uint256 Strength;
        uint256 Toughness;
        uint256 Dexterity;
        
        uint256 Health;
        uint256 CurrentHealth;

        uint256 Damage;
        uint256 DodgeChance;
        uint256 CritChance;
        
        uint256 Level;
        uint256 Experience;
    
        uint256 Age; //Current Block minus Creation Block.
        uint256 Birth;
    
        uint256 UnspentAttributePoints;
        uint256 id;

        Item[] items;
        GladiatorState State;
    }

    event gladiatorinfo(

        string Name,

        uint256 Strength,
        uint256 Toughness,
        uint256 Dexterity,
        
        uint256 Health,
        uint256 CurrentHealth,

        uint256 Damage,
        uint256 DodgeChance,
        uint256 CritChance,
        
        uint256 Level,
        uint256 Experience,
    
        uint256 Birth,
    
        uint256 UnspentAttributePoints,
        //uint256 id,

        Item head,
        Item chest,
        Item hands,
        Item legs,
        Item boots,
        Item mainhand,
        Item offhand,
        Item twohand,
        Item ring,
        Item ring2,
        Item amulet,

        GladiatorState, state
        //address gladiatorowner
    );

    //Emit where gladiatorstats are updated.

    function ShoutGladiatorInfo(uint256 _id) public {
        name = GetName(Gladiators[_id]);
        str = GetStrength(Gladiators[_id]);
        tou = GetToughness(Gladiators[_id]);
        dex = GetDexterity(Gladiators[_id]);
        hp = GetHealth(Gladiators[_id]);
        chp = GetCurrentHealth(Gladiators[_id]);
        dmg = GetCurrentDamage(Gladiators[_id]);
        dod = GetCurrentDodgeChance(Gladiators[_id]);
        crit =GetCurrentCritChance(Gladiators[_id]);

        age = GetAge(Gladiators[_id]);
        uap = GetUnspentAttributePoints(Gladiators[_id]);

        head = GetItem(_id, "HEAD");
        chest = GetItem(_id, "CHEST");
        hands = GetItem(_id, "HANDS");
        legs = GetItem(_id, "LEGS");
        boots = GetItem(_id, "BOOTS");
        mainhand = GetItem(_id, "MAINHAND");
        offhand = GetItem(_id, "OFFHAND");
        twohand = GetItem(_id, "TWOHAND");
        ring = GetItem(_id, "RING");
        ring2 = GetItem(_id, "RING");
        amulet = GetItem(_id, "AMULET");

        state = GetState(Gladiators[_id]);
        

        emit gladiatorinfo(name,str,tou,dex,hp,chp,dmg,dod,crit,age,uap,head,chest,hands,legs,boots,mainhand,offhand,twohand,ring,ring2,amulet);
    }
    //Modifier for Gladiator owner only actions.

    //Player call this function
    function NewGladiator(string _name) public returns (Gladiator){
        
        Gladiator storage g;
        g.Name = _name;
        g.Strength = rand()%MAX_NUM+1;
        g.Dexterity = rand()%MAX_NUM+1;
        g.Toughness = rand()%MAX_NUM+1;
        g.Health = GetHealth();
        g.CurrentHealth = g.Health;
        g.Damage = g.GetInitialDamage();
        g.DodgeChance = g.GetInitialDodgeChance();
        g.CritChance = g.GetInitialCritChance();

        g.Level = 0;
        g.Experience = 0;
        g.State = GladiatorState.IDLE;
        
        g.Birth = block.number;
        id += 1;
        g.id = id;
        Gladiators[id] = g;
        return g;
    }
    
    modifier IsAlive(Gladiator _g) {
        require(_g.CurrentHealth > 0, "Health is less than 0");
        _;
    }

 //Refactor iator

    //TODO AuctionGladiator
    function AuctionGladiator(uint256 _g) public {
        require(iator(_g).state == GladiatorState.IDLE);

    }
    
    function LevelUp(Gladiator _g) public isAlive(g) returns(bool) {
        require(_g.state == GladiatorState.IDLE, "Gladiator has to be idle");
        if(_g.Experience > ExperienceToNextLevel(g.Level)) {
            _g.Experience = _g.Experience - ExperienceToNextLevel(g.Level);
            _g.Level = _g.Level + 1;
            IncrementUnspentAttributePoints(_g);
            return true;
        }
        return false;
    }

    function IncrementUnspentAttributePoints(Gladiator _g) internal isAlive(g) {
        _g.UnspentAttributePoints += 3;
    }

    function SpendAttributePoint(Gladiator _g, String _s) public isAlive(g) {
        require(_g.UnspentAttributePoints > 0, "You have too few attribute points");
        if(_s == "Strength") { 
            _g.Strength += 1;
            _g.UnspentAttributePoints -= 1;
            }
        else if(_s == "Dexterity") {
            _g.Dexterity += 1;
            _g.UnspentAttributePoints -= 1;
        }
        else if(_s == "Toughness") { 
            _g.Toughness += 1;
            _g.UnspentAttributePoints -= 1;
        }
    }

    function ExperienceToNextLevel(uint256 _level) public pure returns(uint256) {
        require(_level > 0, "Level can't be less than 0");
        return (_level^1.2)*100;
    }

    
    function GetExperience(Gladiator _g, uint256 _amount) internal {
        _g.Experience += _amount;
    }

    function DealDamage(Gladiator _a, Gladiator _b) internal IsAlive(_a) IsAlive(_b) {
        while(_a.CurrentHealth > 0 && _b.CurrentHealth > 0) {
            _a.CurrentHealth -= _b.Damage;
            _b.CurrentHealth -= _a.Damage;
        } 
        if(_a.CurrentHealth < 0) {
            KillGladiator(_a);
            _b.Experience += CalculateExperienceFromGladiator(_a);
            LevelUp(_b);
        }
        if(_b.CurrentHealth < 0) {
            KillGladiator(_b);
            _a.Experience += CalculateExperienceFromGladiator(_b);
            LevelUp(_a);
        }
    }

    function KillGladiator(_g) internal {
        Gladiators[_g.id].IsAlive = false;
    }

    function CalculateExperienceFromGladiator(_g) public pure returns (uint256) {
        return (_g.Strength+_g.Dexterity+_g.Toughness)*_g.Level;
    } 


    //TODO: Find out where to call this to make sure it's called every block
    function CheckRegenerate() public {
        if (block.number > latestblock) {
            Regenerate();
            latestblock = block.number;
        }
    }


    //Gain hp back with incremental blocks.
    function Regenerate(Gladiator _g) internal {
        if(_g.CurrentHealth > _g.Health) {
            _g.CurrentHealth += 1*_g.Level;
            if (_g.CurrentHealth <= _g.Health) {
                _g.CurrentHealth = _g.Health;
            }
        }
    }
    
    function Fight(Gladiator _g, bool _pvp, uint256 _id) internal {
        
        if(_pvp) {
            against = GetGladiator(_id);
        }
        else {
            against = GetMonster(_id);
        }


        DealDamage();
        GetExperience(_g,1000);
        LevelUp(_g);       
    }

    function Practice(Gladiator _g) public IsAlive(_g)  {
        require(_g.state == GladiatorState.IDLE, "Gladiator has to be idle");
        _g.State = GladiatorState.PRACTICE;
        transfer(owner,1000);
        GetExperience(_g,1000);
        LevelUp(_g);
        _g.State = GladiatorState.IDLE;
    }

    function FightMonster(Gladiator _g, uint256 _m) public IsAlive(_g) {
        require(_g.state == GladiatorState.IDLE, "Gladiator has to be idle");
        _g.State = GladiatorState.FMONSTER;
        GetMonster(_m);
        Fight(_g,false,_m);

        _g.State = GladiatorState.IDLE;
    }

    function FightPlayer(Gladiator _g, uint256 _tofight) public IsAlive(_g) {
        require(_g.state == GladiatorState.IDLE, "Gladiator has to be idle");
        _g.State = GladiatorState.FPLAYER;
        Fight(_g,true,_m)
        _g.State = GladiatorState.IDLE;
    }

    function EmitCombat(uint256 _a, uint256 _b) public {

    }

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

    uint256 constant RES_COST = 500; 

    //Purchase a resurrectionstone and resurrect target gladiator.
    function ResurrectionStone(uint256 _gladiatorindex) public {
        transfer(owner, RES_COST);
        Gladiators[_gladiatorindex].IsAlive = true; 
    }
    
    function rand() private view returns (uint256){
        uint256 seedInt = uint256(seedHash)/2;
        seedInt += block.timestamp;
        return uint256(sha256(abi.encodePacked(seedInt)));
    }
    

    function GetPlayerGladiators(address _a) public view returns (Gladiator[]) {
        return _a.OwnedGladiators;
    }
    function GetPlayerBalance(address _a) public view returns (uint256) {
        return _a.Token;
    }


    function iator(uint256 _i) public view returns (Gladiator) {
        return Gladiators[_i];
    }

    function GetName(Gladiator _g) public pure returns (string) {
        return _g.Name;
    }
    //Primary Attributes
    function GetStrength(Gladiator _g)  public pure returns(uint256) { 
        return _g.Strength;
    }
    
    function GetDexterity(Gladiator _g) public pure returns(uint256) { 
        return _g.Dexterity;
    }
    
    function GetToughness(Gladiator _g) public pure returns(uint256) { 
        return _g.Toughness;
    }

    function GetLevel(Gladiator _g) public pure returns(uint256) { 
        return _g.Level;
    }
    
    function GetExperience(Gladiator _g) public pure returns(uint256) { 
        return _g.Experience;
    }
    
    //Secondary Attributes
    function GetInitialHealth(uint256 _t) private pure returns (uint256) {
        return _t*2;
    }
    function GetInitialDamage(uint256 _s) private pure returns(uint256) { 
        return _s*2;
    }
    function GetInitialCritChance(uint256 _d) private pure returns(uint256) { 
        return _d*2;
    }
    function GetInitialDodgeChance(uint256 _d) public pure returns(uint256) { 
        return _d*2;
    }

    function GetCurrentHealth(Gladiator _g) public pure returns (uint256) {
        return _g.CurrentHealth;
    }
    
    function GetCurrentDamage(Gladiator _g) public pure returns (uint256) {
        return _g.Damage;
    }
    
    function GetCurrentCritChance(Gladiator _g) public pure returns (uint256) {
        return _g.CritChance;
    }
    
    function GetCurrentDodgeChance(Gladiator _g) public pure returns (uint256) {
        return _g.DodgeChance;
    }

    function GetAge(Gladiator _g) public pure returns (uint256) {
        return block.number - _g.age; 
    }

    function GetUnspentAttributePoints(Gladiator _g) public pure returns (uint256) {
        return _g.UnspentAttributePoints;
    }

    function GetItem(uint256 _g,string _s) public view returns (Item) {
        return ItemsOnGladiator[_g][_s];
    }
} 