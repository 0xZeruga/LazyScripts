pragma solidity ^0.4.24;

import "./SafeSol/Ownable.sol";
import "./SafeSol/StorageState.sol";

interface token {
    function transfer(address receiver, uint amount) external;
}

contract MyToken is StorageState , Ownable {

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address centralMinter
    ) public {
        totalSupply = initialSupply;
        if(centralMinter != 0) owner = centralMinter;
    }

    uint public minBalanceForAccounts;

    function setMinBalance(uint minimumBalanceInFinney) public onlyOwner {
        minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }

    function mintToken(address target, uint256 mintedAmount) public onlyOwner {
        _storage.setTokensForAddress(target, mintedAmount);
        emit Transfer(0, owner, mintedAmount);
        emit Transfer(owner, target, mintedAmount);
    }

    uint256 public sellPrice;
    uint256 public buyPrice;

    //setPrices(1000000000000000,500000000000000)

    //Set prices by owner
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    //Buy Tokens by sending Ethereum to contract
    function buy() public payable returns (uint256 amount) {
        amount = msg.value / buyPrice;
        transfer(msg.sender, amount);
        return amount;
    }

    //Sell Tokens and get ethereum back
    function sell(uint256 amount) public returns (uint256) {
        require(balanceOf[msg.sender] >= amount,"Not enough money");
        balanceOf[this] += amount;
        balanceOf[msg.sender] -= amount;
        uint256 revenue = amount * sellPrice;
        msg.sender.transfer(revenue);
        emit Transfer(msg.sender, this, amount);
        return revenue;
    }

    function transfer(address _to, uint256 _value) public {
        /* Check if sender has balance and for overflows */
        require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to], "Insufficient balance");

        /* Add and subtract new balances */
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        /* Notify anyone listening that this transfer took place */
        if(_to.balance<minBalanceForAccounts) {
            //_to.send(sell((minBalanceForAccounts - _to.balance) / sellPrice));
            emit Transfer(msg.sender,_to,(sell((minBalanceForAccounts - _to.balance) / sellPrice)));
        } else {
            emit Transfer(msg.sender, _to, _value);
        }

    }
}
