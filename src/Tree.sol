// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "solmate/tokens/ERC721.sol";
import "./Resources.sol";
import {Hevm} from "hevm/Hevm.sol";

contract Tree is ERC721 {
    uint256 public _remainingSaplings = 10_000;
    mapping(uint256 => uint256) private treeCreatedBlock;
    address private _resourceContract;

    constructor(address resourceContract) ERC721("TREE", "TREE") {
        _resourceContract = resourceContract;
    }

    function ClaimSapling(address _to) external {
        require(_remainingSaplings != 0);
        _safeMint(_to, _remainingSaplings);
        treeCreatedBlock[_remainingSaplings] = block.number;
        _remainingSaplings = _remainingSaplings - 1;
    }

    function ChopDown(uint256 id) external {
        require(ownerOf[id] == msg.sender);
        _burn(id);
        Resources(_resourceContract).mintWood(
            msg.sender,
            block.number - treeCreatedBlock[id]
        );
    }

    function tokenURI(uint256 id) public view override returns (string memory){
        return "eoghan.dev";
    }
}
