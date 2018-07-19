pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CryptoArtifacts is ERC721Token("CryptoArtifacts", "CA"), Ownable {

    uint currentSet = 0;
    uint numberOfSlots = 9;
    uint lootboxesLeft = 10000;

    struct Artifact {
        uint set;
        uint slot;
        uint power;
        uint bonus;
    }

    mapping (uint => Artifact) artifacts;

    mapping (address => uint[]) equipped;

    function equip(address _player, uint _artifact, uint _slot) public {

    }

    function updateGame(uint _newCurrentSet, uint _newNumberOfSlots, uint _newLootboxesLeft) onlyOwner public {
        currentSet = _newCurrentSet;
        numberOfSlots = _newNumberOfSlots;
        lootboxesLeft = _newLootboxesLeft;
    }

    function openLootboxes(uint _amount) public {
        require(lootboxesLeft >= _amount);
        lootboxesLeft.sub(_amount);
        uint id = allTokens.length.add(1);
        _mint(msg.sender, id);
        artifacts[id] = Artifact(0, 0, 1, 0);
    }

}