
///TODO Refactor this class
//GOAL 500 lines.
//TODO Auction

pragma solidity 0.4.24;

import "./SafeSol/StorageState.sol";
import "./SafeSol/Ownable.sol";

/// @author Jacob Eriksson
contract Game is StorageState, Ownable {
    
    ///AUCTION
    //TODO AuctionGladiator
    function AuctionGladiator(uint256 _g) public {
        require(GetGladiator(_g).state == GladiatorState.IDLE);
    }
    
    ///EXPERIENCE && LEVELIN

    uint256 constant POINTS_ON_LEVELUP = 3;

    function LevelUp(bytes32 _g) public returns (bool) {
        Gladiator g = [msg.sender].OwnedGladiators[_g];
        require(g.state == GladiatorState.IDLE, "Gladiator has to be idle");
        if(g.Experience > ExperienceToNextLevel(g.Level)) {
            g.Experience = g.Experience - ExperienceToNextLevel(g.Level);
            g.Level = g.Level + 1;
            IncrementUnspentAttributePoints(g, POINTS_ON_LEVELUP);
            return true;
        }
        return false;
    }

    function IncrementUnspentAttributePoints(bytes32 _g, uint256 amount) internal {
        Gladiator g = [msg.sender].OwnedGladiators[_g];
        g.UnspentAttributePoints += amount;
    }

    function SpendAttributePoint(bytes32 _g, string _s) public {
        Gladiator g = [msg.sender].OwnedGladiators[_g];
        require(g.UnspentAttributePoints > 0, "You have too few attribute points");
        if(_s == "Strength") { 
            g.Strength += 1;
            g.UnspentAttributePoints -= 1;
            }
        else if(_s == "Dexterity") {
            g.Dexterity += 1;
            g.UnspentAttributePoints -= 1;
        }
        else if(_s == "Toughness") { 
            g.Toughness += 1;
            g.UnspentAttributePoints -= 1;
        }
    }

    function CheckSpendableAttributePoints(bytes32 _g, uint256 str, uint256 dex, uint256 tou) public {
        Gladiator g = [msg.sender].OwnedGladiators[_g];
        uint256 sum = str+dex+tou;
        require(g.GetUnspentAttributePoints >= sum);
        g.strength += str;
        g.dexterity += dex;
        g.toughness += tou;
        g.IncrementUnspentAttributePoints(_g, -sum);
        [msg.sender].OwnedGladiators[_g] = g;
    }

    function ExperienceToNextLevel(uint256 _level) public pure returns(uint256) {
        require(_level > 0, "Level can't be less than 0");
        return (_level^1.2)*100;
    }

    function (uint256 _g, uint256 _amount) internal {
        _storage.GetGladiator(_id).Experience += _amount;
    }

    function CalculateExperienceFromFight(uint256 hp, uint256 dmg, uint256 level) public pure returns (uint256) {
       return (hp+dmg)*level;
    }
    
    ///GLADIATOR
    //Emit where gladiatorstats are updated.
    function ShoutGladiatorInfo(bytes32 _id) public {
        Gladiator g = _gladiatorStorage[key];

        emit gladiatorinfo(
            g.name,g.strength,g.toughness,g.dexterity,
            g.maxHealth,g.currentHealth, g.damage,
            g.dodgeChance,crit,age,uap,head,chest,hands,legs,boots,mainhand,offhand,twohand,ring,ring2,amulet);


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

    function AddNewGladiatorToStorage(address _sender, string name) public {

        Gladiator memory g;
        g.owner = [msg.sender];
        g.name = _name;

        g.strength = 5;
        g.dexterity = 5;
        g.toughness = 5;
        g.health = GetHealth();
        g.currentHealth = g.Health;
        g.damage = g.GetInitialDamage();
        g.dodgeChance = g.GetInitialDodgeChance();
        g.critChance = g.GetInitialCritChance();

        g.level = 0;
        g.experience = 0;
        g.unspentAttributePoints = 10;

        g.birth = block.number;
        _storage.setGladiatorID();
        g.id = _storage.getGladiatorID();

        g.killedGladiators = 0;
        g.killedMonster = 0;

        g.state = GladiatorState.IDLE;
        g.items = Item[];

        _storage.msg.sender.OwnedGladiators[g.id] = g;
        _storage.setGladiator(g.id, g);
    }

    function DeleteGladiator(uint256 _id) public {
        require([msg.sender] == _storage.GetGladiator(_id).owner);
        delete _storage._gladiatorStorage[_id];
        delete _storage.msg.sender.OwnedGladiators[_id];
    }

    function size() public returns (uint) {
        return AllGladiators.length;
    }

    function GetAllGladiators() public {
        for(i = 0; i < AllGladiators.size(); i++) {
           _storage.GetGladiator(i);
        }
    }



    function AddMonsterToStorage(
        string _name, string _description,
        string _levelspan, uint256 _health,
        uint256 _dmg, uint256 _crit, 
        uint256 _dodge) public onlyOwner() {

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

    //TODO: Populate with more monsters.
    //Name, description, level-span, health, damage, crit, dodge
    function PopMonster() public onlyOwner() {
        AddMonsterToStorage("Goblin Warrior", "A tiny greenskin with a wooden spear", "1-3",10,3,4,4);
        AddMonsterToStorage("Cyclop", "A 15 feet one-eyed giant with leatherlike skin", "8-11",120,25,20,5);
    }

    function DeleteMonster(bytes32 _name) public onlyOwner() {
        delete _storage._monsterStorage[_name];
    }
    //TODO Continue refactoring from here.
    function GetPlayerGladiators(address _a) public view returns (mapping(address=> mapping(address => uint256))) {
        return _a.OwnedGladiators;
    }
    function GetPlayerBalance(address _a) public view returns (uint256) {
        return _a.OwnedTokens;
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
    
    function GetTotalExperience(Gladiator _g) public pure returns(uint256) { 
        return _g.Experience;
    }
    
    //Secondary Attributes
    function GetInitialHealth(uint256 _t) private pure returns (uint256) {
        return _t*2;
    }
    
    function GetMaxHealth(Gladiator _g) public pure returns (uint256) {
        return _g.maxHealth;
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
        return _g.currentHealth;
    }
    
    function GetCurrentDamage(Gladiator _g) public pure returns (uint256) {
        return _g.damage;
    }
    
    function GetCurrentCritChance(Gladiator _g) public pure returns (uint256) {
        return _g.critChance;
    }
    
    function GetCurrentDodgeChance(Gladiator _g) public pure returns (uint256) {
        return _g.dodgeChance;
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

    //SETTERS
    function Health(Gladiator _g, uint256 _amount) {
        _g.currentHealth += _amount;
        if(_g.currentHealth > GetMaxHealth(_g)) {
            _g.currentHealth = GetMaxHealth(_g);
        }
        if(_g.currentHealth <= 0) {
            _g.currentHealth = 0;
        }
    }

    ///COMBAT
    function Practice(Gladiator _g) public IsAlive(_g)  {
        require(_g.state == GladiatorState.IDLE, "Gladiator has to be idle");
        _g.State = GladiatorState.PRACTICE;
        transfer(owner,1000);
        (_g,1000);
        LevelUp(_g);
        _g.State = GladiatorState.IDLE;
    }

    function PreFight(Gladiator _g, uint256 _tofight) public IsAlive(_g) {
        require(_g.state == GladiatorState.IDLE, "Gladiator has to be idle");
        _g.State = GladiatorState.FPLAYER;
        Fight(_g,true,_m);
        _g.State = GladiatorState.IDLE;
    }

    function Fight(Gladiator _g, bool _pvp, bytes32 _name) internal {
        
        if(_pvp) {
            //TODO: Fix get functions
            Gladiator player = _storage.GetGladiator(_name);
            DealDamage(_g, player);
        }
        else {
              //TODO: Fix get functions
            Monster monster = _storage.GetMonster(_name);
            DealDamage(_g, monster);
        }
    }

    function DealDamage(Gladiator _a, Monster _m) internal IsAlive(_a) {
        require(_a.state = State.IDLE);
        uint256 dmgsum = 0;
        while(GetCurrentHealth(_a) >0 && dmgsum <= m.health) {
            //PLAYER ALWAYS ATTACKS FIRST IN MONSTERFIGHTS.
            CombatTurn(_a,_m);
            CombatTurn(_m,_a);
        } 
        if(GetCurrentHealth(_a) <= 0) {
            KillGladiator(_a);
        } 
        else if(dmgsum <= m.health) {
            (_a,CalculateExperienceFromFight(_m.health, _m.dmg, _m.level));
        }
    }

    function DealDamage(Gladiator _a, Gladiator _b) internal IsAlive(_a) IsAlive(_b) {
        require(_a.state = State.IDLE && _b.state == State.IDLE);
        while(GetCurrentHealth(_a) > 0 && GetCurrentHealth(_a) > 0) {
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
        if(GetCurrentHealth(_a) <= 0) {
            KillGladiator(_a);
            (_b, CalculateExperienceFromFight(GetMaxHealth(_a), GetCurrentDamage(_a), GetLevel(_a)));
            LevelUp(_b);
        }
        if(GetCurrentHealth(_b) <= 0) {
            KillGladiator(_b);
            (_a, CalculateExperienceFromFight(GetMaxHealth(_b), GetCurrentDamage(_b), GetLevel(_b)));
            LevelUp(_a);
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

    //VS Monster
    function CombatTurn(Gladiator _a, Monster _m) private {
    //Check dodge
        if(rand()%MAX_NUM+1 <= _a.GetCurrentDodgeChance()) {
            emit dodgeinfo(_a.name,_m.name);
        }
        //Check crit
        else if(rand()%MAX_NUM+1 <= _b.GetCurrentCritChance()) {
            //TODO: Add crit bonus depending on weapon.
            _a.CurrentHealth -= _m.Damage*2;
            emit critinfo(_a.name,_m.name,_m.items["MAINHAND"], _m.GetCurrentDamage()*2);
        }
        else {
            _a.CurrentHealth -= _m.Damage;
            emit hitinfo(_a.name,_m.name,_m.items["MAINHAND"], _m.GetCurrentDamage());
        }
    }

    //VS PLAYER
    function CombatTurn(Gladiator _a, Gladiator _b) private {
    //Check dodge
        if(rand()%MAX_NUM+1 <= _a.GetCurrentDodgeChance()) {
            emit dodgeinfo(_a.name,_b.name);
        }
        //Check crit
        else if(rand()%MAX_NUM+1 <= _b.GetCurrentCritChance()) {
            //TODO: Add crit bonus depending on weapon.
            _a.CurrentHealth -= _b.Damage*2;
            emit critinfo(_a.name,_b.name,_b.items["MAINHAND"], _b.GetCurrentDamage()*2);
        }
        else {
            _a.CurrentHealth -= _b.Damage;
            emit hitinfo(_a.name,_b.name,_b.items["MAINHAND"], _b.GetCurrentDamage());
        }
    }



    function KillGladiator(Gladiator _killed, Gladiator _killer) private {
        _killer.killedGladiators += 1;
        emit deadgladiator(_killed.name, _killer.name, block.number);
        delete _killed.owner.OwnedGladiators[_killed];
    }

    ///RESURRECTION
    uint256 constant RES_COST = 5000; 

    //Purchase a resurrectionstone and resurrect target gladiator.
    function ResurrectionStone(bytes32 _name) public {
        transfer(owner, RES_COST);
        [msg.sender].OwnedGladiators[_name].IsAlive = true;
    }

    uint256 constant BANDAGE_HEAL_AMOUNT = 100;
    uint256 constant HEALTH_POTION_HEAL_AMOUNT = 500;
    uint256 constant HEALING_MAGIC_HEAL_AMOUNT = 1000;
    uint256 constant BANDAGE_COST = 200;
    uint256 constant HEALTH_POTION_COST = 350;
    uint256 constant HEALING_MAGIC_COST = 500;

    function Healing(uint256 _t, bytes32 _name) public {
        Gladiator g = [msg.sender].OwnedGladiators[_name];
        if(_t==0) {
            transfer(owner,BANDAGE_COST);
            g.SetCurrentHealth(BANDAGE_HEAL_AMOUNT);
            emit healing("Bandage",HEALING_BANDAGE_HEAL_AMOUNT,g);
        } 
        else if(_t==1){
            transfer(owner,HEALTH_POTION_COST);
            g.SetCurrentHealth(HEALTH_POTION_HEAL_AMOUNT);
            emit healing("Potion",HEALING_POTION_HEAL_AMOUNT,g);
        } 
        else if(_t==2){
            transfer(owner,HEALING_MAGIC_COST);
            g.SetCurrentHealth(HEALING_MAGIC_HEAL_AMOUNT);
            emit healing("Magic",HEALING_MAGIC_HEAL_AMOUNT,g);
        } 
    }

    ///ITEMS
    /// @param a is the name of item
    /// @param b is the slot of item

    function AddItemToStorage(
        string name, string slot, string description,
        uint256 strengthbonus, uint256 toughnessbonus, uint256 dexteritybonus,
        uint256 healthbonus, uint256 damagebonus, uint256 dodgebonus,
        uint256 critbonus, uint256 duration)
        public isOwner() {
            Item memory item;
            item.name = name;
            item.slot = slot;
            item.description = description;
            item.strength_bonus = strengthbonus;
            item.toughness_bonus = toughnessbonus;
            item.dexterity_bonus = dexteritybonus;
            item.health_bonus = healthbonus;
            item.damage_bonus = damagebonus;
            item.dodge_bonus = dodgebonus;
            item.crit_bonus = critbonus;
            item.duration = duration;

            _storage.setItem(item.name, item);
    }

   //Deletes item from shop but item will still remain in peoples inventory.
    //TODO: Solve this
    function DeleteItem(uint256 _item) public isOwner() {
        delete ItemsInShop[_item];
    }

    function PopShop() public {
        AddItemToStorage("Cloth Cap","A ragged piece of cloth","HEAD",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("Leather Cap","Hardened leather hat", "HEAD",0,0,0,0,0,0,0,0,200);
        AddItemToStorage("Chainmail hood", "Links of chain","HEAD",0,0,0,0,0,0,0,0,0,400);

        AddItemToStorage("","","SHOULDERS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","SHOULDERS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","SHOULDERS",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","CHEST",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","CHEST",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","CHEST",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","BRACERS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","BRACERS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","BRACERS",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","HANDS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","HANDS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","HANDS",0,0,0,0,0,0,0,0,100);

         AddItemToStorage("","","WAIST",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","WAIST",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","WAIST",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","LEGS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","LEGS",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","LEGS",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","FEET",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","FEET",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","FEET",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","MAINHAND",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","MAINHAND",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","MAINHAND",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","OFFHAND",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","OFFHAND",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","OFFHAND",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","TWOHAND",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","TWOHAND",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","TWOHAND",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","RING",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","RING",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","RING",0,0,0,0,0,0,0,0,100);

        AddItemToStorage("","","AMULET",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","AMULET",0,0,0,0,0,0,0,0,100);
        AddItemToStorage("","","AMULET",0,0,0,0,0,0,0,0,100);
    }

    function EquipItem(uint256 _gladindex, string _item) {
        Item item = _storage.GetItem(_item);
        Gladiator glad = [msg.sender].OwnedGladiators[_gladindex];
        if(CheckSlotTaken(glad,item.slot)) {
            //Remove bonuses stored on the current equipment place
            UpdateItemBonuses(_glad, glad.items[item.slot], false);
        }
        UpdateItemBonuses(_glad, _glad[item.slot], true);
       [msg.sender].OwnedGladiators[glad] = getItem(item.name);
    }

    function CheckSlotTaken(Gladiator _glad, string _s) internal returns (bool) {
        if(_glad.items[_s]!=""){return true;}
        else{ return false;}
    }
    
    function UpdateItemBonuses(Gladiator glad, Item i, bool apply) internal {
        if(apply) {
            glad.Strength += i.strength_bonus;
            glad.Toughness += i.toughness_bonus;
            glad.Dexterity += i.dexterity_bonus;
            glad.Health += i.health_bonus;
            glad.Damage += i.damage_bonus;
            glad.DodgeChance += i.dodge_bonus;
            glad.CritChance += i.crit_bonus;
        } else {
            glad.Strength -= i.strength_bonus;
            glad.Toughness -= i.toughness_bonus;
            glad.Dexterity -= i.dexterity_bonus;
            glad.Health -= i.health_bonus;
            glad.Damage -= i.damage_bonus;
            glad.DodgeChance -= i.dodge_bonus;
            glad.CritChance -= i.crit_bonus;
        }
    }

    function GetItemType(uint256 _itemID) public returns (string) {
        return ItemsInShop[_itemID].slot;
    }

    function PurchaseItem(uint256 gladindex, uint256 itemid) public {
        uint256 pricenew = ItemsInShop[itemid].price;
        transfer(owner, pricenew);
        EquipItem(gladindex,item);
    }

    //Equipment bind to gladiator
    //Equipment modifiers apply to gladiator
    //Emit GladiatorUpdate to storage
} 