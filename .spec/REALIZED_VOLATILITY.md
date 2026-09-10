\[
     \begin{aligned}
       \sigma_K = 16.000 (\textrm{uint88}) \\
       L(\sigma) = 100.000 = 100.000 \times 1\mathrm{e}8 \\
       \bar L = \frac{L(\sigma)}{\sigma_K^2} \\
       \pi^{\sigma} = \bar L \times (\sigma(i(t))^2 - \sigma_K^2)
      \end{aligned}
\]
`
``
We can create a cron that serves as a foundry script that generates TickHIstory taht realizes a level of volatility. This is:

Given that we have 12 seconds per block AND we have a limit of 30_000_000 gas per block, we are faced an optimization problem:

We need the minimum number, ContractualVaultPayoff is a vault that tracks the contractual payoff value measured in numeriaire as vol

Define the constant:

\[
\begin{aligned}
	\mathrm{Window} = 24\times 60 \times 60
\end{aligned}
\]

and then:

\[
	\begin{aligned}
		\mathrm{Vol} (\mathrm{Window}; t) \, &= (\mathrm{Window})^{-1} \times \sum_{t=t_{\text{now}} - \text{Window}}^{t_{\text{now}}} \Big [i(t_{\text{now}}) \, - \, i_{\mu} (t)\Big ]^2
	\end{aligned}
\]

Define:

\[
	\begin{aligned}
		\mathrm{TickState} \{ \\
		 \quad i(t)\\
		 
		 \quad \textrm{update ()} \\
		 \quad \textrm{get ()} \\
 		\} 
	\end{aligned}
\]





TickState{
	update() --->  TickVariance{
	  |                   TickState.get()
	  |	 				              ----------v 
	  |              }                  update(   ,   )
}     |                                          ----^ 
       -------> TickAverage {                   |
	                i_{u}                       |
					update (tickState.get())    |
					get()   --------------------
                 }


- Now we want a realized-volatility factory. This is:

The convention is, lets stablish a fixed time frequency \(\bar dt\). and start \(t_0 \leftarrow \bar t\); This gives:

\[
	\begin{aligned}
		t_1 \leftarrow t_0 + \bar dt \\
		\cdots \\
		t_i \leftarrow t_{i-1} + \bar dt
	\end{aligned}
\]

\[
	\begin{aligned}
		\textrm{Window} = \sum_{i=0}^{\text{Window}/\bar dt} \bar t_i
	\end{aligned}
\]

which give us a sequence of timestamps \(T = \{t_i\}_{i=0}^{N}\quad N =\frac{\text{Window}}{\bar dt}\);

Define:

\[
	\begin{aligned}
		\sigma_{\text{factory}} : T \times \bar \sigma \to \text{TickPath} \equiv \{i\}_{j=0}^{N}
	\end{aligned}
\]


Note that \(\sigma_{\text{factory}}\) is a *discrete time control macro*, formally:

\[
	\begin{aligned}
		i(t) = A\cdot i(t-1) + B \cdot u \\
		\sigma (t) = C \cdot i(t) + D \cdot u 
	\end{aligned}
\]

with terminal condition: 

\[
	\begin{aligned}
		\sigma (N) = \bar \sigma 
	\end{aligned}
\]


Then:

\[
	\begin{aligned}
		C \leftarrow \frac{\partial \sigma (t)}{\partial i(t)} = \, 2 (W)^{-1} \, \sum [i - i_{\mu}]
	\end{aligned}
\]

And the terminal condition imposes structure on \(u\).

\[
	\begin{aligned}
		u(N) \, &= \, D^{T} \, D^{-1} \, \Big [\bar  \sigma \, - \, C\cdot i(N)\Big]
	\end{aligned}
\]
