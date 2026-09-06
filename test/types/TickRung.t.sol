// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlankTestBase} from "test/PlankTestBase.sol";

interface ITickRung {
    function tickRung(int256 tickVal, uint256 rawTickSpacing, uint24 step) external view returns (int256);
}

/// @title TickRungTest
/// @notice Suite for {types/TickRung.plk} — Tick(i, Δ) + LegStep · TickSpacing(Δ).
contract TickRungTest is PlankTestBase {
    ITickRung internal harness;

    function setUp() public {
        harness = ITickRung(deployPlank("test/harness/types/TickRungHarness.plk"));
    }

    function test__unit__tickRung_fromTickAndStep() public view {
        int256 tickVal = int256(100);
        uint256 rawTs = 60;
        uint24 step = 3;

        int256 got = harness.tickRung(tickVal, rawTs, step);

        // Tick(100, 60) snaps to floor spacing; then + 3 * TickSpacing(60).
        int256 spacing = int256(60);
        int256 q = tickVal / spacing;
        if (tickVal % spacing != 0 && tickVal < 0) {
            q -= 1;
        }
        int256 expected = q * spacing + int256(uint256(step)) * spacing;

        assertEq(got, expected);
    }
}
