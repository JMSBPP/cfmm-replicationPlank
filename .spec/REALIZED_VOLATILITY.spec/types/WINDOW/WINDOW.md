[MAIN](.spec/REALIZED_VOLATILITY.md)

\[
\begin{aligned}
	\mathrm{Window} = 24\times 60 \times 60
\end{aligned}
\]


[REF::`uint32 internal constant WINDOW = 1 days;`](node_modules/@cryptoalgebra/volatility-oracle-plugin/contracts/libraries/VolatilityOracle.sol)

```
├ Hex: 0x15180
├ Hex (full word): 0x0000000000000000000000000000000000000000000000000000000000015180
└ Decimal: 86400
```

\[
	\begin{aligned}
		(\mathrm{Window})^{-1}
	\end{aligned}
\]

```
uint32 internal constant WINDOW = 1 days;
```
\[
	\begin{aligned}
		\textrm{Window} = \sum_{i=0}^{N} \bar t_i \\
		\\
		N =\frac{\text{Window}}{\bar dt}
	\end{aligned}
\]


# How is it used on REF ?

TimePoint \((t) = \{ \sigma (t), i(t), i_{\mu} (t) \cdots\}\)

TimeContainer = TimePoint[UINT16_MODULO]

The library defines an index `windowStartIndex`

```
uint16 windowStartIndex; // closest timepoint lte WINDOW seconds ago (or oldest timepoint), _should be used only from last timepoint_!
```

> This implies that WINDOW role is being a upper bound

- `windowStartIndex` 

Provides means to interact with:

///   getTwapTick(uint32,int24,uint32)            → 0x1a72d0df  (period, tick, time)
///   initializeTWAP(uint32,int24)                → 0xed64c40a
///   writeTimepoint(uint32,int24)                → 0xb09b2297
///   canGetTwap(uint32,uint32)                   → 0x4a513c98
///   getSingleTimepoint(uint32,uint32,int24)     → 0xf1a0ebe5  (secondsAgo, time, tick)
///   getTimepoints(uint32[],uint32,int24)        → 0x36ab33e3
///   getAverageVolatilityLast(uint32,int24)      → 0x59dc9384

