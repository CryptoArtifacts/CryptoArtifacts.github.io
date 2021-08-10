// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/security/PullPayment.sol";


contract CryptoArtifacts is ERC721Enumerable, ERC721URIStorage,  Ownable, PullPayment {
    
    uint constant initialLootboxes = 21000;
    uint public lootboxesLeft = initialLootboxes;
    
    mapping(uint => uint) public artifacts;
    
    event LootboxOpened(address by, uint tokenId, uint artifactId);
    
    constructor() ERC721("CryptoArtifacts", "CA") { }
    
    function random(uint lower, uint upper) private view returns (uint) {
        return (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, lootboxesLeft))) % (upper-lower)) + lower;
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
        uint lootboxesSold = initialLootboxes - lootboxesLeft;
        return lootboxesSold * lootboxesSold / 1000000000 / 1 ether;
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function openLootbox() public payable {
        require(lootboxesLeft >= 1, "no lootboxes left");
        require(msg.value >= getCurrentPrice(), "invalid price");
        
        lootboxesLeft = lootboxesLeft - 1;
        uint _id = totalSupply();
        artifacts[_id] = rollArtifactId();
        _mint(msg.sender, _id);
        _setTokenURI(_id, uint2str(artifacts[_id]));

        emit LootboxOpened(msg.sender, _id, artifacts[_id]);
    }
    
    function _baseURI() override internal pure returns (string memory) {
        return "https://cryptoartifacts.co/";
    }
    
    function withdraw(uint amount) public onlyOwner returns(bool) {
        require(amount <= address(this).balance);
        address payable owner = payable(owner());
        _asyncTransfer(owner, amount);
        return true;
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    
    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
