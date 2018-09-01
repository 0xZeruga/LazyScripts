
pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./Game.sol";

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
    function buy() payable return (uint amount) {
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
        if(_to.balance<minBalanceForAccounts);
            _to.send(sell((minBalanceForAccounts - _to.balance) / sellPrice));
        emit Transfer(msg.sender, _to, _value);
    }
}
