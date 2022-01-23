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

    // burn removes tree ownership
    function testCanChopDownTree() public {
        tree.ClaimSapling(address(1));
        require(tree.ownerOf(10_000) == address(1));
        hevm.prank(address(1));
        tree.ChopDown(10_000);
    }

    // chopped down tree doesnt belong to former owner
    function testChopDownRevokesOwnership() public {
        tree.ClaimSapling(address(1));
        require(tree.ownerOf(10_000) == address(1));
        hevm.prank(address(1));
        tree.ChopDown(10_000);
        hevm.expectRevert("ERC721: owner query for nonexistent token");
        tree.ownerOf(10_000);
    }

    // chopped down tree belongs to nobody
    function testChopDownBurns() public {
        tree.ClaimSapling(address(1));
        require(tree.ownerOf(10_000) == address(1));
        hevm.prank(address(1));
        tree.ChopDown(10_000);
        hevm.expectRevert("ERC721: owner query for nonexistent token");
        tree.ownerOf(10_000);
    }

    // chopped down tree transfers correct wood to chopper
    function testChopDownTransfersWood(uint256 blockDiff) public {
        tree.ClaimSapling(address(1));
        require(tree.ownerOf(10_000) == address(1));
        hevm.prank(address(1));

        // age the tree
        hevm.roll(blockDiff);
        tree.ChopDown(10_000);

        // assert that chopped down tree produced (AGE) wood.
        require(resources.balanceOf(address(1), 0) == blockDiff);
    }
}
