
pragma solidity ^0.4.24;


import "./MyToken.sol";
import "./Purchase.sol";
import "./Game.sol";


contract Shop {
    

    //Maps item id to item
    mapping(uint256=>Item)ItemsInShop;

    //Maps gladiator id to string array to item
    mapping(uint256=>mapping(string=>Item))ItemsOnGladiator;

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
        uint256 price;
    }


    function PopShop() public {
        Item storage a = Item("Cloth Cap","A ragged piece of cloth","HEAD",0,0,0,0,0,0,0,0,100);
        //TODO: Add plenty of cool items.
    }

    function AddItem(
        string a, string b, string c,
        uint256 d, uint256 e, uint256 f,
        uint256 g, uint256 h, uint256 i,
        uint256 j, uint256 k)
        public isOwner() {
        Item storage n = Item(a,b,c,d,e,f,g,h,i,j,k);
        ItemsInShop.push(n);
    }

    //Deletes item from shop but item will still remain in peoples inventory.
    //TODO: Solve this
    function DeleteItem(uint256 _item) public isOwner() {
        delete ItemsInShop[_item];
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
