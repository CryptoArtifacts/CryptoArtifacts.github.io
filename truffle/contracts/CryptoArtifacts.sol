pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CryptoArtifacts is ERC721Token("CryptoArtifacts", "CA"), Ownable {

    uint currentSet = 0;
    uint numberOfSlots = 9;
    uint lootboxesLeft = 10000;
    uint maxPower = 4;
    uint maxBonus = 3;
    
    uint packPrice = 500 szabo;

    struct Artifact {
        uint set;
        uint slot;
        uint power; // aka type
        uint bonus; // aka variant
    }

    mapping (uint => Artifact) artifacts;

    mapping (address => uint[]) equipped;
    
    function random(uint64 upper) public returns (uint64 randomNumber) {
        uint _seed = lootboxesLeft;
        _seed = uint64(sha3(sha3(blockhash(block.number), _seed), now));
        return _seed % upper;
    }

    function equip(uint _artifactId) public {
        require(ownerOf(_artifactId) == msg.sender);
        uint _slot = artifacts[_artifactId].slot;
        equipped[msg.sender][_slot] = _artifactId;
    }

    function updateGame(uint _currentSet, uint _numberOfSlots, uint _lootboxesLeft) onlyOwner public {
        require(_currentSet > currentSet);
        currentSet = _currentSet;
        numberOfSlots = _numberOfSlots;
        lootboxesLeft = _lootboxesLeft;
    }
    
    function getCurrentPrice() returns (uint) {
        return lootboxesLeft.mul(lootboxesLeft).mul(2000000000000000).div(1000000);
    }
    
    function updatePrice() {
        packPrice = getCurrentPrice();
    }

    function openLootboxes(uint _number) public payable {
        require(lootboxesLeft >= _number);
        require(_number >= 1);
        require(msg.value >= calculateOpenPrice(_number));
        
        for (uint i = 0; i < _number; i++) {
            openOneLootbox();
        }
    }
    
    function openOneLootbox() {
        lootboxesLeft = lootboxesLeft.sub(1);
        updatePrice();
        uint _id = allTokens.length.add(1);
        _mint(msg.sender, _id);
        artifacts[_id] = generateArtifact();
        _setTokenURI(_id, "https://cryptoartifacts.co/artifactimages/" 
            + artifacts[_id].set 
            + "-" + artifacts[_id].slot 
            + "-" + artifacts[_id].power 
            + "-" + artifacts[_id].bonus );
    }
    
    function calculateOpenPrice(_number) returns (uint) {
        // 1 usd = 2000000000000000 wei
        uint total = 0;
        for (uint i = 0; i < _number; i++) {
            total.add(getCurrentPrice());
        }
        return total;
    }
    
    function generateArtifact() returns (Artifact) {
        uint _slot = random(numberOfSlots);
        uint _power = random(maxPower);
        uint _bonus = random(maxPower - 1);
        return Artifact(currentSet, _slot, _power, _bonus);
    }

}
