pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CryptoArtifacts is ERC721Token("CryptoArtifacts", "CA"), Ownable {

    uint constant public initialLootboxes = 10000;
    uint constant public numberOfSlots = 9;

    uint public lootboxesLeft = 10000;
    uint public packPrice = 0;

    struct Artifact {
        uint slot;
        uint power; // aka rarity
    }

    mapping (uint => Artifact) public artifacts;

    mapping (address => uint[]) public equipped;
    
    mapping (address => bool) public existingPlayers;
    address[] public listOfPlayers;
    
    event LootboxesOpened(uint number, address by);
    event ArtifactEquipped(Artifact artifact, address by);
    event NewPlayer(address playerAddress);
    
    function random(uint upper) public view returns (uint) {
        return uint(blockhash(block.number-1 * lootboxesLeft * listOfPlayers.length * block.timestamp)) % upper + 1;
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
    
    function updateListOfPlayers() private {
        require(existingPlayers[msg.sender] == false, "added player must be new");
        listOfPlayers.push(msg.sender);
        existingPlayers[msg.sender] == true;
        emit NewPlayer(msg.sender);
    }

    function equip(uint _artifactId) public {
        require(ownerOf(_artifactId) == msg.sender, "only owner can equip item");
        uint _slot = artifacts[_artifactId].slot;
        equipped[msg.sender][_slot] = _artifactId;
        emit ArtifactEquipped(artifacts[_artifactId], msg.sender);
    }
    
    function getCurrentPrice() public view returns (uint) {
        uint lootboxesSold = initialLootboxes.sub(lootboxesLeft);
        return lootboxesSold.mul(lootboxesSold).mul(2000000000000000).div(1000000);
    }
    
    function updatePrice() private {
        packPrice = getCurrentPrice();
    }

    function openLootboxes(uint _number) public payable {
        require(lootboxesLeft >= _number, "no lootboxes left");
        require(_number >= 1, "number of lootboxes to open must be 1 or more");
        require(msg.value >= calculateOpenPrice(_number), "invalid price");
        
        for (uint i = 0; i < _number; i++) {
            openOneLootbox();
        }
        
        updateListOfPlayers();
        emit LootboxesOpened(_number, msg.sender);
    }
    
    function openOneLootbox() private {
        lootboxesLeft = lootboxesLeft.sub(1);
        updatePrice();
        uint _id = allTokens.length.add(1);
        _mint(msg.sender, _id);
        artifacts[_id] = generateArtifact();
        setTokenURI(_id, artifacts[_id].slot, artifacts[_id].power);
    }
    
    function calculateOpenPrice(uint _numberOfLootboxes) private view returns (uint) {
        // 1 usd = 2000000000000000 wei
        uint total = 0;
        for (uint i = 0; i < _numberOfLootboxes; i++) {
            total.add(getCurrentPrice());
        }
        return total;
    }
    
    function generateArtifact() private view returns (Artifact) {
        uint _slot = random(numberOfSlots);
        uint _power = rollPower();
        return Artifact(_slot, _power);
    }

    function appendUintToString(string _inStr, uint _v) private view returns (string str) {
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
        uint uriId = initialLootboxes.mul(slot).add(power);

        string memory uri = "https://cryptoartifacts.co/artifactimages/";

        _setTokenURI(
            id, 
            appendUintToString(uri, uriId)
        );
    }

}
