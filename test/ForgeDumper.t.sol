// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {ForgeDumper} from "../src/ForgeDumper.sol";
import {Counter} from "../src/Counter.sol";

contract ForgeDumperTest is Test {
    string constant basePath = "dumpStates/base.json";
    Counter public counter;
    Counter public throwawayCounter;

    function setUp() public {
        throwawayCounter = new Counter();
        // Redeploy the contract to compare the difference between dumping with base and without base
        counter = new Counter();
        counter.setNumber(1);
        ForgeDumper.dumpState(basePath);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 2);
        vm.warp(block.timestamp + 1000);
        ForgeDumper.dumpState(basePath, "dumpStates/test_Increment.json");
        ForgeDumper.dumpState("dumpStates/test_Increment_without_base.json");

        string memory dumpWithoutBase = vm.readFile("dumpStates/test_Increment_without_base.json");
        string memory dumpWithBase = vm.readFile("dumpStates/test_Increment.json");

        // Check that the dump without base is missing the throwaway counter address in the accounts object
        string memory throwawayCounterKey =
            string.concat(".accounts.", vm.toLowercase(vm.toString(address(throwawayCounter))));
        assertTrue(!vm.keyExistsJson(dumpWithoutBase, throwawayCounterKey));
        assertTrue(vm.keyExistsJson(dumpWithBase, throwawayCounterKey));
    }

    function test_Increment2() public {
        counter.increment2();
        assertEq(counter.number2(), 1);
        ForgeDumper.dumpState(basePath, "dumpStates/test_Increment2.json");
        ForgeDumper.dumpState("dumpStates/test_Increment2_without_base.json");

        string memory dumpWithoutBase = vm.readFile("dumpStates/test_Increment2_without_base.json");
        string memory dumpWithBase = vm.readFile("dumpStates/test_Increment2.json");

        // Check that the dump without base is missing the throwaway counter address in the accounts object
        string memory throwawayCounterKey =
            string.concat(".accounts.", vm.toLowercase(vm.toString(address(throwawayCounter))));
        assertTrue(!vm.keyExistsJson(dumpWithoutBase, throwawayCounterKey));
        assertTrue(vm.keyExistsJson(dumpWithBase, throwawayCounterKey));

        // Check that the dump without base is missing storage slot 0 information
        string memory storageSlot0Key = string.concat(
            ".accounts.",
            vm.toLowercase(vm.toString(address(counter))),
            ".storage.0x0000000000000000000000000000000000000000000000000000000000000000"
        );
        assertTrue(!vm.keyExistsJson(dumpWithoutBase, storageSlot0Key));
        assertTrue(vm.keyExistsJson(dumpWithBase, storageSlot0Key));

        // Check that both dumps correctly have the storage slot 1 information
        string memory storageSlot1Key = string.concat(
            ".accounts.",
            vm.toLowercase(vm.toString(address(counter))),
            ".storage.0x0000000000000000000000000000000000000000000000000000000000000001"
        );
        assertTrue(vm.keyExistsJson(dumpWithBase, storageSlot1Key));
        assertTrue(vm.keyExistsJson(dumpWithoutBase, storageSlot1Key));
        assertTrue(vm.parseJsonUint(dumpWithBase, storageSlot1Key) == 1);
        assertTrue(vm.parseJsonUint(dumpWithoutBase, storageSlot1Key) == 1);
    }
}
