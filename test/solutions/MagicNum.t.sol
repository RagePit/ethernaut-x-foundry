pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/MagicNum/MagicNumFactory.sol";
import "../../src/Ethernaut.sol";
import "../utils/vm.sol";

contract MagicNumTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testMagicNum() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        MagicNumFactory magicNumFactory = new MagicNumFactory();
        ethernaut.registerLevel(magicNumFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(magicNumFactory);
        MagicNum ethernautMagicNum = MagicNum(payable(levelAddress));


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        /**
          PUSH10	602a60005260206000F3
          PUSH1	00
          MSTORE	
          PUSH1	0a
          PUSH1	16
          RETURN
         */

        bytes memory code = hex"69602a60005260206000F3600052600a6016f3";
        address addr;
        assembly {
          addr := create(0, add(code, 0x20), mload(code))
          if iszero(extcodesize(addr)) {
            revert(0, 0)
          }
        }
        ethernautMagicNum.setSolver(addr);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
