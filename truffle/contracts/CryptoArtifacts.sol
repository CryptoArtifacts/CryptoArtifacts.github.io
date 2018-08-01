pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CryptoArtifacts is ERC721Token("CryptoArtifacts", "CA"), Ownable {

    uint set = 0;
    uint numberOfSlots = 9;
    uint lootboxesLeft = 10000;
    uint packPrice = 500 szabo;

    struct Artifact {
        uint set;
        uint slot;
        uint power; // aka type
        uint bonus; // aka variant
    }

    mapping (uint => Artifact) artifacts;

    mapping (address => uint[]) equipped;
    
    mapping (address => bool) existingPlayers;
    address[] listOfPlayers;
    
    function random(uint64 upper) public returns (uint64 randomNumber) {
        uint _seed = lootboxesLeft;
        _seed = uint64(sha3(sha3(blockhash(block.number), _seed), now));
        return _seed % upper;
    }
    
    function k100() returns (uint) {
        return random(100);
    }
    
    // returns 0,1,2,3
    // 1%, 4%, 25%, 70%
    function distributed4() returns (uint) {
        uint k100 = k100();
        if(k100 <= 1){
            return 3;
        } else if (k100 <= 5) {
            return 2;
        } else if (k100 <= 25) {
            return 1;
        } else {
            return 0;
        }
    }
    
    function updateListOfPlayers() {
        require(existingPlayers[msg.sender] == false);
        listOfPlayers.push(msg.sender);
        existingPlayers[msg.sender] == true;
    }

    function equip(uint _artifactId) public {
        require(ownerOf(_artifactId) == msg.sender);
        uint _slot = artifacts[_artifactId].slot;
        equipped[msg.sender][_slot] = _artifactId;
        updateListOfPlayers();
    }

    function updateGame(uint _set, uint _numberOfSlots, uint _lootboxesLeft) onlyOwner public {
        require(_set > set);
        set = _set;
        numberOfSlots = _numberOfSlots;
        lootboxesLeft = _lootboxesLeft;
    }
    
    function getCurrentPrice() public view returns (uint) {
        return lootboxesLeft.mul(lootboxesLeft).mul(2000000000000000).div(1000000);
    }
    
    function updatePrice() private {
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
    
    function openOneLootbox() private {
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
    
    function calculateOpenPrice(_number) private view returns (uint) {
        // 1 usd = 2000000000000000 wei
        uint total = 0;
        for (uint i = 0; i < _number; i++) {
            total.add(getCurrentPrice());
        }
        return total;
    }
    
    function generateArtifact() private returns (Artifact) {
        uint _slot = random(numberOfSlots);
        uint _power = distributed4() + 1; // 1,2,3,4
        uint _bonus = distributed4(); // 0,1,2,3
        return Artifact(currentSet, _slot, _power, _bonus);
    }

}
