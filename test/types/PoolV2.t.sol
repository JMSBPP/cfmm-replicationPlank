// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlankTestBase} from "test/PlankTestBase.sol";

interface IPoolV2 {
    function setChainId(uint256 chainId) external;
}

/// @title PoolV2Test
/// @notice Dual-fork scaffold plus PoolV2Harness deploy; smoke-calls setChainId.
contract PoolV2Test is PlankTestBase {
    IPoolV2 internal harness;
    uint256 internal forkA;
    uint256 internal forkB;

    function setUp() public {
        string[] memory cmd = new string[](2);
        cmd[0] = "just";
        cmd[1] = "init-chains";
        vm.ffi(cmd);

        forkA = vm.createFork(vm.rpcUrl("chainA"));
        forkB = vm.createFork(vm.rpcUrl("chainB"));

        harness = IPoolV2(deployPlank("test/harness/types/PoolV2Harness.plk"));
    }

    function test__unit__forksAndHarness() public {
        // createFork ids are 0-based; first fork is a valid id 0.
        assertTrue(forkA != forkB);
        assertTrue(address(harness) != address(0));

        harness.setChainId(31337);
    }
}
