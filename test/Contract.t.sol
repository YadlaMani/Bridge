// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/Panda.sol";
import "../src/MPanda.sol";
import "../src/BridgeETH.sol";
import "../src/BridgeBase.sol";

contract TestContract is Test {
    Panda p;
    MPanda mp;
    BridgeETH beth;
    BridgeBase base;
    address user = 0xF201248A5433094D3DC9457066Fb5Ad96aD0BF87;

    function setUp() public {
        p = new Panda();
        mp = new MPanda();
        beth = new BridgeETH(address(p));
        base = new BridgeBase(address(mp));
        p.mint(user, 200);
        mp.mint(address(base), 1000);
    }

    function testLocking() public {
        vm.startPrank(user);
        p.approve(address(beth), 200);
        beth.lock(IERC20(p), 100);
        assertEq(
            p.balanceOf(user),
            100,
            "User's token balance should be 100 after locking"
        );
        assertEq(
            beth.pendingBalance(user),
            100,
            "Pending balance in BridgeETH should be 100"
        );
        vm.stopPrank();
    }

    function testUnlocking() public {
        vm.startPrank(user);
        p.approve(address(beth), 200);
        beth.lock(IERC20(address(p)), 100);
        beth.unlock(IERC20(address(p)), 50);
        assertEq(
            p.balanceOf(user),
            150,
            "User's token balance should be 150 after unlocking"
        );
        assertEq(
            beth.pendingBalance(user),
            50,
            "Pending balance in the BridgeEth should be 50"
        );
        vm.stopPrank();
    }

    function testBurningOnOtherSide() public {
        vm.startPrank(user);
        p.approve(address(beth), 200);
        beth.lock(IERC20(address(p)), 100);
        vm.stopPrank();
        vm.prank(address(this));
        beth.burnedOnOtherSide(user, 100);
        assertEq(
            beth.pendingBalance(user),
            200,
            "Pending balance should be increase by 100"
        );
    }

    function testMinting() public {
        base.depositedOnOtherSide(user, 100);
        assertEq(
            base.pendingBalance(user),
            100,
            "Pending balance in BridgeBase should be 100"
        );

        base.withdraw(user, IBUSDT(address(mp)), 100);
        assertEq(
            mp.balanceOf(user),
            100,
            "User's token balance in MPanda should be 100"
        );
        assertEq(
            base.pendingBalance(user),
            0,
            "Pending balance in BridgeBase should be 0"
        );
    }

    function testBurning() public {
        vm.prank(address(this));
        base.depositedOnOtherSide(user, 100);
        vm.startPrank(user);
        base.burn(IBUSDT(address(mp)), 100);
        assertEq(
            mp.balanceOf(user),
            0,
            "User's token balance in MPanda should be 0 after burning"
        );
        assertEq(
            base.pendingBalance(user),
            0,
            "Pending balance in Bridgebase should be 0 after burning"
        );
        vm.stopPrank();
    }
}
