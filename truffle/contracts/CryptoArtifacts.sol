pragma solidity ^0.5.9;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/master/contracts/token/ERC721/ERC721Full.sol";

contract CryptoArtifacts is ERC721Full("CryptoArtifacts", "CA") {

    uint public lootboxesLeft = 10000;

    uint constant lootboxPrice = 20000000000000000; // 0.02 eth
    
    mapping(uint => uint) public artifacts;
    
    event LootboxOpened(address by, uint tokenId, uint artifactType);
    
    function random(uint lower, uint upper) private view returns (uint) {
        return uint(blockhash(block.number-1 * lootboxesLeft)) % upper + lower;
    }
    
    // returns 1-80
    // 1%, 4%, 25%, 70%
    function rollArtifactId() private view returns (uint) {
        uint k100roll = random(1, 100);
        if(k100roll <= 1){
            return random(61, 80);
        } else if (k100roll <= 5) {
            return random(31, 60);
        } else if (k100roll <= 25) {
            return random(21, 40);
        } else {
            return random(1, 20);
        }
    }
    

    function openLootbox() public payable {
        require(lootboxesLeft >= 1, "no lootboxes left");
        require(msg.value >= lootboxPrice, "invalid price");
        
        lootboxesLeft = lootboxesLeft.sub(1);
        //uint totalSupply = totalSupply();
        uint _id = totalSupply();
        _mint(msg.sender, _id);
        artifacts[_id] = rollArtifactId();
        
        emit LootboxOpened(msg.sender, _id, artifacts[_id]);
    }

}
