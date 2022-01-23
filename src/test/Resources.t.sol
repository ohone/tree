// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../Tree.sol";
import {Hevm} from "hevm/Hevm.sol";

contract ResourcesTest is DSTest, Hevm {
    Resources resources;

    function setUp() public {
        resources = new Resources();
    }

    function testMintWoodUnauthorizedCannotTransfer() public {
        // act as unathorized 3rd party
        hevm.prank(address(1));

        // mint
        hevm.expectRevert("Sender not authorized.");
        resources.mintWood(address(2), 10);
    }

    function testOwnerCanSetAuthorizedMinters(address addr) public {
        resources.addApprovedAddress(addr);
        resources.isAuthorized(addr);
    }

    function testAuthorizedCanMint(address addr, uint256 amount) public {
        // add authorized user
        resources.addApprovedAddress(addr);

        // mint wood
        resources.mintWood(address(1), amount);
    }

    function testMintWoodTransfersAmount(address addr, uint256 amount) public {
        // add authorized user
        resources.addApprovedAddress(addr);

        // mint wood
        resources.mintWood(address(1), amount);

        // assert wood transferred
        require(resources.balanceOf(address(1), 0) == amount);
    }
}
