pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/ownership/Ownable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/ERC721Full.sol";


contract CryptoArtifacts is ERC721Full, Ownable {
    
    uint constant initialLootboxes = 10000;
    uint public lootboxesLeft = initialLootboxes;
    uint constant priceConstant = 5000000000000000; // 0.005 eth
    
    mapping(uint => uint) public artifacts;
    
    event LootboxOpened(address by, uint tokenId, uint artifactId);
    
    constructor() ERC721Full("CryptoArtifacts", "CA") public { }
    
    function random(uint lower, uint upper) private view returns (uint) {
        return (uint(keccak256(abi.encodePacked(now, msg.sender, lootboxesLeft))) % (upper-lower)) + lower;
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
    
    function getCurrentPrice() public view returns (uint) {
        uint lootboxesSold = initialLootboxes.sub(lootboxesLeft);
        return lootboxesSold.mul(lootboxesSold).mul(priceConstant).div(1000000);
    }
    
    function toString(uint _base) internal pure returns (string memory) {
        bytes memory _tmp = new bytes(32);
        uint i;
        for(i = 0;_base > 0;i++) {
            _tmp[i] = bytes1((uint8(_base) % 10) + 48);
            _base /= 10;
        }
        bytes memory _real = new bytes(i--);
        for(uint j = 0; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        return string(_real);
    }

    function openLootbox() public payable {
        require(lootboxesLeft >= 1, "no lootboxes left");
        require(msg.value >= getCurrentPrice(), "invalid price");
        
        lootboxesLeft = lootboxesLeft.sub(1);
        uint _id = totalSupply();
        artifacts[_id] = rollArtifactId();
        _mint(msg.sender, _id);
        _setTokenURI(_id, toString(artifacts[_id]));

        emit LootboxOpened(msg.sender, _id, artifacts[_id]);
    }
    
    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }
    
    function withdraw(uint amount) public onlyOwner returns(bool) {
        require(amount <= address(this).balance);
        address payable owner = payable(owner());
        owner.transfer(amount);
        return true;
    }

}
