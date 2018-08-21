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

    function uint2str(uint _i) internal pure returns (string){
        if (_i == 0) return "0";
        uint j = _i;
        uint i = _i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function setTokenURI(uint id, uint slot, uint power) private {
        uint uriId = initialLootboxes.mul(slot).add(power);

        string memory url_1 = "https://cryptoartifacts.co/artifactimages/";
        string memory url_2 = uint2str(uriId);

        _setTokenURI(
            id, 
            strConcat(url_1, url_2, "", "", "")
        );
    }

}
