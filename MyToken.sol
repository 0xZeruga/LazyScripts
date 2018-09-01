
pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./MyToken.sol";

interface token {
    function transfer(address receiver, uint amount) external;
}

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract MyToken is owned {

    uint256 public totalSupply;
    mapping(address=> uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);


    function MyToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address centralMinter
    ) {
        totalSupply = initialSupply;
        if(centralMinter != 0) owner = centralMinter;
    }

    uint public minBalanceForAccounts;

    function setMinBalance(uint minimumBalanceInFinney) onlyOwner {
        minBalanceForAccount = minimumBalanceInFinney * 1 finney;
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, owner, mintedAmount);
        emit Transfer(owner, target, mintedAmount);
    }

    uint256 public sellPrice;
    uint256 public buyPrice;

    //setPrices(1000000000000000,500000000000000)

    //Set prices by owner
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    //Buy Tokens by sending Ethereum to contract
    function buy() payable returns (uint amount) {
        amount = msg.value / buyPrice;
        _transfer(this, msg.sender, amount);
        return amount;
    }

    //Sell Tokens and get ethereum back
    function sell(uint amount) returns (uint amount) {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[this] += amount;
        balanceOf[msg.sender] -= amount;
        revenue = amount * sellPrice;
        msg.sender.transfer(revenue);
        Transfer(msg.sender, this, amount);
        return revenue;
    }

    function transfer(address _to, uint256 _value) public {
        /* Check if sender has balance and for overflows */
        require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);

        /* Add and subtract new balances */
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        /* Notify anyone listening that this transfer took place */
        if(_to.balance<minBalanceForAccounts) {
            _to.send(sell((minBalanceForAccounts - _to.balance) / sellPrice));
        }
        emit Transfer(msg.sender, _to, _value);
    }
}

contract Game {
    
     constructor() public {
        id = 0;
        latestblock = block.number;
    }
    
    //Called once Ether is sent to the account.
    function () payable public {
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.mintToken(msg.sender, amount/price);
        emit FundTransfer(msg.sender, amount, true);
    }

    mapping(address=>Player)Players;
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
    
    enum FightType {
        PRACTICE,
        MONSTER,
        PLAYER
    }
    
    struct Gladiator {

        address Owner;

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
        
    }

    //Modifier for Gladiator owner only actions.
    
    function NewGladiator() public returns (Gladiator){
        
        Gladiator memory g;
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
        
        g.Birth = now;
        id += 1;
        g.id = id;
        Gladiators[id] = g;
        return g;
    }
    
    modifier IsAlive(Gladiator _g) {
        require(_g.CurrentHealth > 0);
        _;
    }


    function AuctionGladiator() public {
    }
    
    function LevelUp(Gladiator _g) isAlive(g) public returns(bool) {
        if(_g.Experience > ExperienceToNextLevel(g.Level)) {
            _g.Experience = _g.Experience - ExperienceToNextLevel(g.Level);
            _g.Level = _g.Level + 1;
        }
    }

    function IncrementUnspentAttributePoints(Gladiator _g) isAlive(g) {
        _g.UnspentAttributePoints +=3;
    }

    function SpendAttributePoint(Gladiator _g, String _s) isAlive(g) public {
        require(_g.UnspentAttributePoints > 0);
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

    function ExperienceToNextLevel(uint256 _level) returns public pure (uint256) {
        require(_level > 0);
        return (_level^1.2)*100;
    }

    
    function GetExperience(Gladiator _g, uint256 _amount) returns public pure {
        _g.Experience += _amount;
    }

    function DealDamage(Gladiator _a, Gladiator _b) IsAlive(_a) IsAlive(_b) {
        while(_a.CurrentHealth > 0 && _b.CurrentHealth > 0) {
            _a.CurrentHealth -= _b.Damage;
            _b.CurrentHealth -= _a.Damage;
        } 
        do {
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
    }

    function KillGladiator(_g) {
        Gladiators[_g.id].IsAlive = false;
    }

    function CalculateExperienceFromGladiator(_g) returns public pure (uint256) {
        return (_g.Strength+_g.Dexterity+_g.Toughness)*_g.Level;
    } 


    if(block.number > latestblock) {
        Regenerate();
        latestblock = block.number;
    }

    //Gain hp back with incremental blocks.
    function Regenerate(Gladiator _g) {
        if(_g.CurrentHealth > _g.Health) {
            _g.CurrentHealth += 1*_g.Level;
            if (_g.CurrentHealth <= _g.Health) {
                _g.CurrentHealth = _g.Health;
            }
        }
    }
    
    function Fight(FightType _f, Gladiator _g) {
        if(_f == FightType.PRACTICE) {
            transfer(owner,)
        } else if(_f == FightType.MONSTER) {

            
        } else if(_f == FightType.PLAYER) {
            //Choose Player, return b.
            //TODO:Check dodge chance
            //TODO:Check critchance
            DealDamage()
        } else {
            //ERROR
        }
    }

    uint256 constant RES_COST = 500; 

    //Purchase a resurrectionstone and resurrect target gladiator.
    function ResurrectionStone(uint256 _gladiatorindex) {
        transfer(owner, RES_COST);
        Gladiators[_gladiatorindex].IsAlive = true; 
    }

//TODO:
//Fighting
    
    function rand() private view returns (uint256){
        uint256 seedInt = uint256(seedHash)/2;
        seedInt += now;
        return uint256(sha256(abi.encodePacked(seedInt)));
    }
    

    function GetPlayer(address _a) public view returns (Gladiator[], uint256) {
        return _a.OwnedGladiators, _a.Token;
    }


    function GetGladiator(uint256 _i) public view returns (Gladiator) {
        return Gladiators[_i];
    }
    
    //Primary Attributes
    function GetStrength(Gladiator _g) pure public returns(uint256) { 
        return _g.Strength;
    }
    
    function GetDexterity(Gladiator _g) pure public returns(uint256) { 
        return _g.Dexterity;
    }
    
    function GetToughness(Gladiator _g) pure public returns(uint256) { 
        return _g.Toughness;
    }

    function GetLevel(Gladiator _g) pure public returns(uint256) { 
        return _g.Level;
    }
    
    function GetExperience(Gladiator _g) pure public returns(uint256) { 
        return _g.Experience;
    }
    
    //Secondary Attributes
    function GetInitialHealth(uint256 _t) pure private returns (uint256) {
        return _t*2;
    }
    function GetInitialDamage(uint256 _s) pure private returns(uint256) { 
        return _s*2;
    }
    function GetInitialCritChance(uint256 _d) pure private returns(uint256) { 
        return _d*2;
    }
    function GetInitialDodgeChance(uint256 _d) pure public returns(uint256) { 
        return _d*2;
    }

    function GetCurrentHealth(Gladiator _g) pure public returns (uint256) {
        return _g.CurrentHealth;
    }
    
    function GetCurrentDamage(Gladiator _g) pure public returns (uint256) {
        return _g.Damage;
    }
    
    function GetCurrentCritChance(Gladiator _g) pure public returns (uint256) {
        return _g.CritChance;
    }
    
    function GetCurrentDodgeChance(Gladiator _g) pure public returns (uint256) {
        return _g.DodgeChance;
    }

    function GetAge(Gladiator _g) pure public returns (uint256) {
        return block.number - _g.age; 
    }
} 