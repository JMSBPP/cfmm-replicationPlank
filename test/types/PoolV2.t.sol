// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlankTestBase} from "test/PlankTestBase.sol";

/// @title PoolV2Test
/// @notice Dual-fork scaffold: FFI `just init-chains`, then fork chainA / chainB from
///         foundry.toml `[rpc_endpoints]`.
contract PoolV2Test is PlankTestBase {
    uint256 internal forkA;
    uint256 internal forkB;

    function setUp() public {
        string[] memory cmd = new string[](2);
        cmd[0] = "just";
        cmd[1] = "init-chains";
        vm.ffi(cmd);

        forkA = vm.createFork(vm.rpcUrl("chainA"));
        forkB = vm.createFork(vm.rpcUrl("chainB"));
    }

    function test__unit__forksCreated() public view {
        assertTrue(forkA != 0);
        assertTrue(forkB != 0);
        assertTrue(forkA != forkB);
    }
}
