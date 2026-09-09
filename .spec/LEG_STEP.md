

\[
	\begin{aligned}
		\mathrm{LegStep} \, \equiv \Big\{ i_{-}, i_{+}, \Delta_i\Big\} \to \frac{i_{+} - i_{-}}{\Delta_i}
	\end{aligned}
\]
[LegStepImpl](src/types/LegStep.plk)
 
[LegStepHarness](test/harness/types/LegStepHarness.plk)
 ```
 		let ts = TickSpacing(@evm_calldataload(4));
		let step = LegStep(TickBucket(ts), ts);
```

## LEG_STEP_LIBRARIES

B (#) -> B


