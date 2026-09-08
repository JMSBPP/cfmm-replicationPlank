// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlankTestBase} from "test/PlankTestBase.sol";

interface IPoolV2 {
    function setChainId(uint256 chainId) external;
    function readChainId() external view returns (uint256);
}

/// @title PoolV2Test
/// @notice Dual-fork PoolV2Harness: set on A, assert isolation on B, read back on A.
contract PoolV2Test is PlankTestBase {
    IPoolV2 internal harnessA;
    IPoolV2 internal harnessB;
    uint256 internal forkA;
    uint256 internal forkB;
    uint256 internal recordedIdA;
    uint256 internal recordedIdB;

    function setUp() public {
        string[] memory cmd = new string[](2);
        cmd[0] = "just";
        cmd[1] = "init-chains";
        vm.ffi(cmd);

        forkA = vm.createFork(vm.rpcUrl("chainA"));
        forkB = vm.createFork(vm.rpcUrl("chainB"));
        assertTrue(forkA != forkB);

        vm.selectFork(forkA);
        harnessA = IPoolV2(deployPlank("test/harness/types/PoolV2Harness.plk"));
        assertTrue(address(harnessA) != address(0));

        vm.selectFork(forkB);
        harnessB = IPoolV2(deployPlank("test/harness/types/PoolV2Harness.plk"));
        assertTrue(address(harnessB) != address(0));
    }

    function test__unit__poolChainId() public {
        vm.selectFork(forkA);
        recordedIdA = block.chainid;
        harnessA.setChainId(recordedIdA);

        vm.selectFork(forkB);
        recordedIdB = block.chainid;
        assertTrue(recordedIdB != recordedIdA);
        assertTrue(recordedIdB != 0);
        assertEq(harnessB.readChainId(), 0);

        vm.selectFork(forkA);
        assertEq(harnessA.readChainId(), recordedIdA);
    }
}
