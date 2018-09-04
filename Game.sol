
///TODO Refactor this class

pragma solidity ^0.4.24;

import "./SafeSol/StorageState.sol";

contract Game is StorageState{
    
    constructor() public {
        id = 0;
        latestblock = block.number;
    }
    
    bytes32 private seedHash;
    
    uint256 public latestblock;

    uint public price;
    token public tokenReward;
 
    ///AUCTION
    //TODO AuctionGladiator
    function AuctionGladiator(uint256 _g) public {
        require(gladiator(_g).state == GladiatorState.IDLE);
    }
    
    ///EXPERIENCE && LEVELIN
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



    function CalculateExperienceFromGladiator(_g) public pure returns (uint256) {
        return (_g.Strength+_g.Dexterity+_g.Toughness)*_g.Level;
    } 


    ///REGENERATION
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
    
    ///GLADIATOR
      enum GladiatorState {
        PRACTICE, 
        FMONSTER,
        FPLAYER,
        IDLE
    }

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

    modifier IsAlive(Gladiator _g) {
        require(_g.CurrentHealth > 0, "Health is less than 0");
        _;
    }


    function AddNewGladiatorToStorage(address _sender, string name) public {

        Gladiator memory g;
        g.owner = [msg.sender];
        g.name = _name;

        g.strength = rand()%MAX_NUM+1;
        g.dexterity = rand()%MAX_NUM+1;
        g.toughness = rand()%MAX_NUM+1;
        g.health = GetHealth();
        g.currentHealth = g.Health;
        g.damage = g.GetInitialDamage();
        g.dodgeChance = g.GetInitialDodgeChance();
        g.critChance = g.GetInitialCritChance();

        g.level = 0;
        g.experience = 0;
        g.unspentAttributePoints = 0;

        g.birth = block.number;
        setGladiatorID();
        g.id = getGladiatorID();

        g.state = GladiatorState.IDLE;
        g.items = Item[];

        [msg.sender].Gladiators[g.id] = g;
        _storage.setGladiator(g.name, g);
    }

    function DeleteGladiator(address _owner) public {
        require(_owner == g.owner);
        //TODO:Delete.
    }

    struct Gladiator {

        address owner;
        string name;

        uint256 strength;
        uint256 toughness;
        uint256 dexterity;
        uint256 health;
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

        Item[] items;
        GladiatorState state;
    }

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

        GladiatorState state
    );

    ///MONSTER
        constructor() public {
        AddMonsterToStorage("Goblin Warrior", "A tiny greenskin with a wooden spear", "1-3",10,3,4,4);
        AddMonsterToStorage("Cyclop", "A 15 feet one-eyed giant with leatherlike skin", "8-11",120,25,20,5);
    }

    function AddMonsterToStorage(
        string _name, string _description,
        string _levelspan, uint256 _health,
        uint256 _dmg, uint256 _crit, 
        uint256 _dodge) public isOwner() {

        Monster memory m;
        m.name = _name;
        m.description = _description;
        m.levelspan = _levelspan;
        m.health = _health;
        m.damage = _dmg;
        m.crit = _crit;
        m.dodge = _dodge;
    
        _storage.setMonster(m.name, m);
        emit MonsterInfo(m.name,m.description,m.levelspan,m.health,m.damage,m.crit,m.dodge);
    }

    function DeleteMonster() public isOwner() {

    }

    struct Monster {
        string name;
        string description;
        string levelspan;
        uint256 health;
        uint256 damage;
        uint256 crit;
        uint256 dodge;
    }

    event MonsterInfo(
        string name,
        string description,
        string levelspan,
        uint256 health,
        uint256 damage,
        uint256 crit,
        uint256 dodge  
    );

    ///RESURRECTION
    uint256 constant RES_COST = 500; 

    //Purchase a resurrectionstone and resurrect target gladiator.
    function ResurrectionStone(uint256 _gladiatorindex) public {
        transfer(owner, RES_COST);
        Gladiators[_gladiatorindex].IsAlive = true; 
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

    ///COMBAT
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
        Fight(_g,true,_m);
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
     
    function DealDamage(Gladiator _a, Gladiator _b) internal IsAlive(_a) IsAlive(_b) {
        while(_a.CurrentHealth > 0 && _b.CurrentHealth > 0) {
            //Check if a or b hits first
            if(FirstStriker(_a.GetDexterity,_b.GetDexterity)) {
                CombatTurn(_a,_b);
                CombatTurn(_b,_a);
            } 
            else {
                CombatTurn(_b,_a);
                CombatTurn(_a,_b);
            }
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

    function CombatTurn(Gladiator _a, Gladiator _b) {
    //Check dodge
        if(rand()%MAX_NUM+1 <= _a.GetCurrentDodgeChance()) {
            //emit Dodge
        }
        //Check crit
        else if(rand()%MAX_NUM+1 <= _b.GetCurrentCritChance()) {
            //TODO: Add crit bonus depending on weapon.
            _a.CurrentHealth -= _b.Damage*2;
            emit critinfo();
        }
        else {
            _a.CurrentHealth -= _b.Damage;
            emit hitinfo();
        }
    }

    function FirstStriker(uint256 a, uint256 b) internal returns (bool) {
        if(a>b){
            return true;
        }
        else{
            return false;
        }
    }

    function KillGladiator(_g) internal {
        Gladiators[_g.id].IsAlive = false;
    }

    ///ITEMS
    //AddItemToStorage("Goblin Warrior", "A tiny greenskin with a wooden spear", "1-3",10,3,4,4);

    function AddItemToStorage(
        string a, string b, string c,
        uint256 d, uint256 e, uint256 f,
        uint256 g, uint256 h, uint256 i,
        uint256 j, uint256 k)
        public isOwner() {
            Item memory item;
            item.name = a;
            item.slot = b;
            item.description = c;
            item.strength_bonus = d;
            item.toughness_bonus = e;
            item.dexterity_bonus = f;
            item.health_bonus = g;
            item.damage_bonus = h;
            item.dodge_bonus = i;
            item.crit_bonus = j;
            item.duration = k;

            _storage.setItem(item.name, item);
    }

   //Deletes item from shop but item will still remain in peoples inventory.
    //TODO: Solve this
    function DeleteItem(uint256 _item) public isOwner() {
        delete ItemsInShop[_item];
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

    event ItemInfo(
        string name,
        string description,
        string levelspan,
        uint256 health,
        uint256 damage,
        uint256 crit,
        uint256 dodge  
    );

    function PopShop() public {
        AddItemToStorage("Cloth Cap","A ragged piece of cloth","HEAD",0,0,0,0,0,0,0,0,100);
        //TODO: Add plenty of cool items.
    }

    //TODO: Equipping a new item before selling the old will destroy the old item.
    function EquipItem(uint256 _gladindex, uint256 _itemindex) public {
        Gladiator glad = [msg.sender].OwnedGladiators[_gladindex];
        string item = GetItemType();

        if(CheckSlotsEmpty(glad,item)){
        } 
        else {
            //Equip item.
            if(_s == "HEAD"){
                RemoveItemBonuses(glad,0);
                glad.items[0] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "CHEST"){
                RemoveItemBonuses(glad,1);
                glad.items[1] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "HANDS"){
                RemoveItemBonuses(glad,2);
                glad.items[2] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "LEGS"){
                RemoveItemBonuses(glad,3);
                glad.items[3] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "BOOTS"){
                RemoveItemBonuses(glad,4);
                glad.items[4] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "MAINHAND"){
                RemoveItemBonuses(glad,5);
                glad.items[5] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "OFFHAND"){
                RemoveItemBonuses(glad,6);
                glad.items[6] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "TWOHAND"){
                RemoveItemBonuses(glad,7);
                glad.items[7] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "RING"){
                RemoveItemBonuses(glad,8);
                glad.items[8] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "RING"){
                RemoveItemBonuses(glad,9);
                glad.items[9] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
            if(_s == "AMULET"){
                RemoveItemBonuses(glad,10);
                glad.items[10] = ItemsInShop[_itemindex];
                AddItemBonuses(glad,_itemindex);
            }
        }
    }

    function CheckSlotTaken(Gladiator _glad, string _s) public returns (bool) {
        if(glad.items[0] == item && _s == "HEAD"){return true;}
        if(glad.items[1] == item && _s == "CHEST"){return true;}
        if(glad.items[2] == item && _s == "HANDS"){return true;}
        if(glad.items[3] == item && _s == "LEGS"){return true;}
        if(glad.items[4] == item && _s == "BOOTS"){return true;}
        if(glad.items[5] == item && _s == "MAINHAND"){return true;}
        if(glad.items[6] == item && _s == "OFFHAND"){return true;}
        if(glad.items[7] == item && _s == "TWOHAND"){return true;}
        if(glad.items[8] == item && _s == "RING"){return true;}
        if(glad.items[9] == item && _s == "RING"){return true;}
        if(glad.items[10] == item && _s == "AMULET"){return true;}
        else {return false;}
    }

    function RemoveItemBonuses(Gladiator glad, uint256 i) internal {
        glad.Strength -= glad.items[i].strength_bonus;
        glad.Toughness -= glad.items[i].toughness_bonus;
        glad.Dexterity -= glad.items[i].dexterity_bonus;
        glad.Health -= glad.items[i].health_bonus;
        glad.Damage -= glad.items[i].damage_bonus;
        glad.DodgeChance -= glad.items[i].dodge_bonus;
        glad.CritChance -= glad.items[i].crit_bonus;
    }
    
    function ApplyItemBonuses(Gladiator glad, uint256 i) internal {
        glad.Strength += ItemsInShop[_itemindex].strength_bonus;
        glad.Toughness += ItemsInShop[_itemindex].toughness_bonus;
        glad.Dexterity += ItemsInShop[_itemindex].dexterity_bonus;
        glad.Health += ItemsInShop[_itemindex].health_bonus;
        glad.Damage += ItemsInShop[_itemindex].damage_bonus;
        glad.DodgeChance += ItemsInShop[_itemindex].dodge_bonus;
        glad.CritChance += ItemsInShop[_itemindex].crit_bonus;
    }

    function GetItemType(uint256 _itemID) public returns (string) {
        return ItemsInShop[_itemID].slot;
    }

    function PurchaseItem(uint256 gladindex, uint256 itemid) public {
        uint256 price = ItemsInShop[itemid].price;
        transfer(owner, price);
        EquipItem(gladindex,item);
    }
} 