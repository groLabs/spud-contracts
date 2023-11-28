// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/SpudGame.sol";
import "../contracts/SpudNFT.sol";


contract SpudGameTest is Test {
    SpudGame spudGame;
    Spud spud;
    address player;

    function setUp() public {
        // Deploy the SpudGame contract and the Spud contract within it
        spudGame = new SpudGame();
        spud = spudGame.SPUD();
        player = address(1);

        // Assign some ETH to the player address
        vm.deal(player, 1 ether);

        // Start the game with the player sending the initial fee
        vm.startPrank(player);
        spudGame.startGame{value: 1 ether}();
        vm.stopPrank();
    }

    function testStartGame() public {
        // Check that the game started and the NFT was minted
        (address currentOwner,,,,) = spudGame.getGame(0);
        assertEq(currentOwner, player);
        assertTrue(spud.balanceOf(address(spudGame), 0) == 1);
    }

    function testStealNFT() public {
        // Another player tries to steal the NFT
        address thief = address(2);
        vm.deal(thief, 1 ether);

        vm.startPrank(thief);
        spudGame.stealNFT{value: 1 ether}(0);
        vm.stopPrank();
        
        // Check the new owner is the thief
        (address currentOwner,,,,) = spudGame.getGame(0);
        assertEq(currentOwner, thief);
    }

    function testClaimPrizePool() public {
        // Simulate time passing and the game ending
        vm.warp(block.timestamp + 2 days);

        // Player attempts to claim the prize pool
        vm.startPrank(player);
        spudGame.claimPrizePool(0);
        vm.stopPrank();

        // Check the prize pool was transferred
        uint prizePool = address(spudGame).balance;
        assertEq(prizePool, 0);
    }
}