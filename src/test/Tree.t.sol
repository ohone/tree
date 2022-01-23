// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../Tree.sol";
import {Hevm} from "hevm/Hevm.sol";

contract TreeTest is DSTest, Hevm {
    Resources resources;
    Tree tree;

    function setUp() public {
        resources = new Resources();
        tree = new Tree(address(resources));
        resources.addApprovedAddress(address(tree));
    }

    // mint single
    function testMintSendsToAddress(address addr) public {
        tree.ClaimSapling(addr);
        require(tree.balanceOf(addr) == 1);
    }

    // minting multiple
    function testCanMintMultiple() public {
        while (tree._remainingSaplings() > 1) {
            tree.ClaimSapling(address(1));
            require(
                tree.balanceOf(address(1)) == 10_000 - tree._remainingSaplings()
            );
        }
    }

    // cannot mint after supply drained
    function testFailLimitedSupply() public {
        for (uint256 index = 0; index < 10_000; index++) {
            tree.ClaimSapling(address(1));
        }
        tree.ClaimSapling((address(2)));
    }

    // chopped down tree belongs to nobody
    function testClaimAllBurns(uint16 blockDiff) public {
        address interactor = address(1);
        hevm.startPrank(interactor);

        tree.ClaimSapling(interactor);
        require(tree.ownerOf(10_000) == interactor);
        hevm.roll(blockDiff);

        tree.ClaimTimber(10_000, tree.CurrentCount(10_000));

        require(tree.ownerOf(10_000) == address(0));
    }

    // chopped down tree transfers correct wood to chopper
    function testClaimAllTransfersAmount(uint16 blockDiff) public {
        address interactor = address(1);
        hevm.startPrank(address(1));

        tree.ClaimSapling(interactor);
        require(tree.ownerOf(10_000) == address(1));

        hevm.roll(blockDiff);

        uint256 currentCount = tree.CurrentCount(10_000);
        tree.ClaimTimber(10_000, currentCount);

        require(resources.balanceOf(address(1), 0) == currentCount);
    }

    // TODO: assert reduction amount correct (_ProportionalToClaim)
    function testClaimPartialReducesGrowthRate(uint16 blockDiff) public {
        address interactor = address(1);
        hevm.startPrank(address(1));

        tree.ClaimSapling(interactor);
        require(tree.ownerOf(10_000) == address(1));

        hevm.roll(blockDiff);

        uint256 currentCount = tree.CurrentCount(10_000);
        uint256 claimAmount = currentCount / 2;
        tree.ClaimTimber(10_000, claimAmount);

        (, , uint256 rate) = tree.trees(10_000);
        require(rate < 100);
    }

    // TODO: assert reduction amount correct (_ProportionalToClaim)
    function testClaimPartialReducesTreeSize(uint16 blockDiff) public {
        address interactor = address(1);
        hevm.startPrank(address(1));

        tree.ClaimSapling(interactor);
        require(tree.ownerOf(10_000) == address(1));

        hevm.roll(blockDiff);

        uint256 pre_claim_amount = tree.CurrentCount(10_000);
        uint256 currentCount = tree.CurrentCount(10_000);
        uint256 claimAmount = currentCount / 2;
        tree.ClaimTimber(10_000, claimAmount);

        require(tree.CurrentCount(10_000) < pre_claim_amount);
    }
}
