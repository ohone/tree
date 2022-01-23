// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "solmate/tokens/ERC721.sol";
import "./Resources.sol";
import {Hevm} from "hevm/Hevm.sol";

contract Tree is ERC721 {
    struct TreeState {
        // timestamp of last chop
        uint256 lastChopTimestamp;
        // remaining tree after last chop
        uint256 lastChopRemaining;
        // rate of growth
        uint256 rate;
    }

    // initial sapling count
    uint256 public _remainingSaplings = 10_000;

    // state of trees
    mapping(uint256 => TreeState) public trees;

    address private _resourceContract;

    constructor(address resourceContract) ERC721("TREE", "TREE") {
        _resourceContract = resourceContract;
    }

    function CurrentCount(uint256 id) public view returns (uint256) {
        return
            trees[id].lastChopRemaining +
            ((block.number - trees[id].lastChopTimestamp) * trees[id].rate);
    }

    function CalculateRateReduction(uint256 total, uint256 claimed)
        private
        returns (uint256)
    {
        uint256 remaining = total - claimed;
        if (remaining > 0) {
            return total / remaining;
        }

        // return max reduction
        return
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    function ClaimSapling(address _to) external {
        require(_remainingSaplings != 0);
        _safeMint(_to, _remainingSaplings);

        // set tree state
        trees[_remainingSaplings].lastChopTimestamp = block.number;
        trees[_remainingSaplings].rate = 100;

        // decerement sapling count
        _remainingSaplings = _remainingSaplings - 1;
    }

    function ClaimTimber(uint256 id, uint256 amountToClaim) external {
        // only owner of tree can cut it
        require(ownerOf[id] == msg.sender, "you dont own this");

        // get current size of tree
        uint256 currentCount = CurrentCount(id);

        // assert that amount being claimed is available
        require(currentCount >= amountToClaim, "claiming too much wood");

        uint256 rateReduction = CalculateRateReduction(
            currentCount,
            amountToClaim
        );

        if (rateReduction > trees[id].rate) {
            _burn(id);
            delete trees[id];
        } else {
            trees[id].rate = trees[id].rate - rateReduction;
            trees[id].lastChopRemaining = currentCount - amountToClaim;
            trees[id].lastChopTimestamp = block.number;
        }
        Resources(_resourceContract).mintWood(msg.sender, amountToClaim);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "eoghan.dev";
    }
}
