// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 public number;
    uint256 public number2;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    function setNumber2(uint256 newNumber2) public {
        number2 = newNumber2;
    }

    function increment2() public {
        number2++;
    }
}