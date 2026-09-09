// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlankTestBase} from "test/PlankTestBase.sol";
// reactive-test-lib/=lib/reactive-test-lib/src/
import {ReactiveTest} from "reactive-test-lib/ReactiveTest.sol";
import {ReactiveConstants} from "reactive-test-lib/constants/ReactiveConstants.sol";
import {Deployers} from "v4-core-test/utils/Deployers.sol";



interface IUniswapV4PoolReactive {
    function setSystemContract(address) external;
    function getSystemContract() external returns(uint256);
}
contract PoolV2Test is PlankTestBase, ReactiveTest, Deployers {
    uint256 internal forkA;
    uint256 internal forkB;
    uint256 internal forkReactive;
    address uniswapV4PoolReactive;

    function setUp() public override {
	super.setUp();
        string[] memory cmd = new string[](2);
        cmd[0] = "just";
        cmd[1] = "init-chains";
        vm.ffi(cmd);
 
        forkA = vm.createFork(vm.rpcUrl("chainA"));
	vm.selectFork(forkA);
	deployFreshManager();
	registerChain(address(manager),block.chainid);
	
        forkB = vm.createFork(vm.rpcUrl("chainB"));
        assertTrue(forkA != forkB);

	forkReactive = vm.createFork(vm.rpcUrl("chainReactive"));
        vm.selectFork(forkReactive);
	uniswapV4PoolReactive = deployPlank("src/modules/UniswapV4PoolReactive.plk");
	assertTrue(address(uniswapV4PoolReactive) != address(0));
    }

    function test__setSystemContract__success() public {
	vm.selectFork(forkReactive);
	IUniswapV4PoolReactive(uniswapV4PoolReactive).setSystemContract(address(sys));
	address expectedSysAddress = address(ReactiveConstants.SERVICE_ADDR);
	uint256 resSysAddress = IUniswapV4PoolReactive(uniswapV4PoolReactive).getSystemContract();
	assertEq(expectedSysAddress,address(uint160(resSysAddress)));
	
    }
    

}
