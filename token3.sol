pragma solidity ^0.4.8;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

  
}

contract tokenRecipient {
    
    function receiveApproval(address _from, uint256 _value, address _token, 
         bytes _extraData); 
    
}

contract token {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    
    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function token(uint256 initialSupply,string tokenName,uint8 decimalUnits,string tokenSymbol ) 
    {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
    
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
    
        Transfer(_from, _to, _value);
        return true;
    }

    
    function () payable{ }
    
}

contract MyAdvancedToken is owned, token {

    uint256 public sellPrice;
    uint256 public buyPrice;
  

       function MyAdvancedToken(uint256 initialSupply,string tokenName,uint8 decimalUnits,
                                string tokenSymbol,address centralMinter )
        token (initialSupply, tokenName, decimalUnits, tokenSymbol)
        {
        if(centralMinter != 0 ) owner = centralMinter;      
        balanceOf[owner] = initialSupply;                   
        }


    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() payable 
     {
        if (buyPrice == 0) throw;
        uint256 amount = msg.value / buyPrice;                
        transferFrom(this,msg.sender,amount) ;
                
        uint256 reminder = msg.value - amount*buyPrice ;
        if (!msg.sender.send(reminder)) throw;          
    }

    function sell(uint256 amount) {
        if (sellPrice == 0) throw;
        if (balanceOf[msg.sender] < amount ) throw;        
        transferFrom(msg.sender,this,amount) ;

        if (!msg.sender.send(amount * sellPrice)) {        
            throw;                                         
        } else {
            Transfer(msg.sender, this, amount);           
        }               
    }
}