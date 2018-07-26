pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CryptoArtifacts is ERC721Token("CryptoArtifacts", "CA"), Ownable {

    uint currentSet = 0;
    uint numberOfSlots = 9;
    uint lootboxesLeft = 10000;
    
    uint smallPackPrice = 6 finney;
    uint mediumPackPrice = 20 finney;
    uint bigPackPrice = 40 finney;

    struct Artifact {
        uint set;
        uint slot;
        uint power; // aka type
        uint bonus; // aka variant
    }

    mapping (uint => Artifact) artifacts;

    mapping (address => uint[]) equipped;

    mapping (address => string) playerNames;

    function equip(uint _artifactId) public {
        require(ownerOf(_artifactId) == msg.sender);
        uint slot = artifacts[_artifactId].slot;
        equipped[msg.sender][slot] = _artifactId;
    }

    function updateGame(uint _currentSet, uint _numberOfSlots, uint _lootboxesLeft) onlyOwner public {
        currentSet = _currentSet;
        numberOfSlots = _numberOfSlots;
        lootboxesLeft = _lootboxesLeft;
    }
    
    function updatePricing(uint _small, uint _medium, uint _big) onlyOwner public {
        smallPackPrice = _small;
        mediumPackPrice = _medium;
        bigPackPrice = _big;
    }

    function openLootboxes(uint _amount) public payable {
        require(lootboxesLeft >= _amount);
        require(_amount == 2 || _amount == 7 || _amount == 15);
        require(msg.value == _amount
        lootboxesLeft = lootboxesLeft.sub(_amount);
        uint id = allTokens.length.add(1);
        _mint(msg.sender, id);
        artifacts[id] = Artifact(0, 0, 1, 0);
        _setTokenURI(id, "https://cryptoartifacts.co/artifactimages/" 
            + artifacts[id].set 
            + "-" + artifacts[id].slot 
            + "-" + artifacts[id].power 
            + "-" + artifacts[id].bonus );
    }

}
