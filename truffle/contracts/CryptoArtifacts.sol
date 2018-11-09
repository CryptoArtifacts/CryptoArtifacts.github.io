pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CryptoArtifacts is ERC721Token("CryptoArtifacts", "CA"), Ownable {

    uint constant public initialLootboxes = 10000;
    uint constant public numberOfTypes = 9; 

    uint public lootboxesLeft = 10000;
    uint public packPrice = 0;

    uint constant basePrice = 5000000000000000; // ~1usd

    struct Artifact {
        uint slot; // aka type
        uint power; // aka rarity
    }

    mapping (uint => Artifact) public artifacts;
    
    event LootboxOpened(address by, uint price);
    
    function random(uint upper) public view returns (uint) {
        return uint(blockhash(block.number-1 * lootboxesLeft)) % upper + 1;
    }
    
    function k100() private view returns (uint) {
        return random(100);
    }
    
    // returns 1000,100,10,1
    // 1%, 4%, 25%, 70%
    function rollPower() private view returns (uint) {
        uint k100roll = k100();
        if(k100roll <= 1){
            return 1000;
        } else if (k100roll <= 5) {
            return 100;
        } else if (k100roll <= 25) {
            return 10;
        } else {
            return 1;
        }
    }
    
    function getCurrentPrice() public view returns (uint) {
        uint lootboxesSold = initialLootboxes.sub(lootboxesLeft);
        return lootboxesSold.mul(lootboxesSold).mul(basePrice).div(1000000);
    }
    
    function updatePrice() private {
        packPrice = getCurrentPrice();
    }

    function openLootbox() public payable {
        require(lootboxesLeft >= 1, "no lootboxes left");
        require(msg.value >= getCurrentPrice(), "invalid price");
        
        openOneLootbox();
        
        emit LootboxOpened(msg.sender, msg.value);
    }
    
    function openOneLootbox() private {
        lootboxesLeft = lootboxesLeft.sub(1);
        updatePrice();
        uint _id = allTokens.length.add(1);
        _mint(msg.sender, _id);
        artifacts[_id] = generateArtifact();
        setTokenURI(_id, artifacts[_id].slot, artifacts[_id].power);
    }
    
    function generateArtifact() private view returns (Artifact) {
        uint _slot = random(numberOfTypes);
        uint _power = rollPower();
        return Artifact(_slot, _power);
    }

    function appendUintToString(string _inStr, uint _v) private pure returns (string str) {
        uint v = _v;
        string memory inStr = _inStr;
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }

    function setTokenURI(uint id, uint slot, uint power) private {
        uint uriId = 10 * (slot + 1) + (power + 1);
        // ex: 10 * (0+1) + (0+1) = 11
        // ex2:10 * (8+1) + (8+1) = 99

        string memory uri = "https://cryptoartifacts.co/artifact/";

        _setTokenURI(
            id, 
            appendUintToString(uri, uriId)
        );
    }

}
