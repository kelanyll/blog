---
title: "The intuition behind odds-implied probability"
date: 2022-11-11T00:00:00+00:00
tags: ["probability", "sports-betting"]
hidden: true
---
If you start looking at the maths behind betting you may come across the idea of implied probability. This is where you use the odds offered on an event to calculate an implied probability of different outcomes. For the sake of simplicity I'm going to use decimal odds in this post. 

This is the formula for implied probability where $\pi$ represents the implied probability and $d$ represents the decimal odds.

$$
\pi = 1 / d
$$

Using an example, if the odds of Liverpool beating Manchester City are $4.5$ then the implied probability of this is $1/4.5 \approx$ 22%. The interesting part about this is that if you add up the implied probabilities of all possible outcomes you will, in all likelihood, get over 100%. Here's an example taken from Betfair of the Newcastle vs Chelsea game on 12/11/2022:

|                     | Newcastle Win | Draw | Chelsea Win | Total | 
| --------------------|---------------|------|-------------|-------|
| Decimal odds        | 2.3           | 3.4  | 3.1         |       |
| Implied probability | 43%           | 29%  | 32%         | 104%  |

That 4% is called the overround and it's the bookmakers profit margin - we'll come back to that later. 

Now what seems to be missing from most resources is an explanation for how implied probability make sense intuitively and how it's useful. The answer is that the implied probability is inherently tied to the true probability and I can explain how. 

This formula represents how much profit you would be expected to get on average by offering odds on a single outcome of an event, where $W$ is the sum of all wagers and $P(O)$ is the true probability of that outcome occurring.
$$
\begin{aligned}
E[Profit] &= E[Wagers] - E[Payouts] \\\\\\
&= W - P(O) \cdot W \cdot d
\end{aligned}
$$
To convince you of this:
- Our expected profit will naturally be the amount of money we receive subtracted by the amount of money we pay out.
- Our expected wagers (or the amount of money we receive) will always be the sum of the wagers.
- If the outcome does occur we expect to payout our odds multiplied by the sum of the wagers we receive and this is expected to occur with probability $P(O)$.

Lets say we want to provide odds on the outcome of an event such that we break even on average and we know for sure that there is a 20% chance of that outcome occurring. So $E[Profit] = 0$ and $P(O) = 0.2$.
$$
\begin{aligned}
0 &= W - 0.2 \cdot W \cdot d \\\\\\
0 &= 1 - 0.2 \cdot d \\\\\\
d &= 1/0.2 \\\\\\
d &= 5 \\\\\\
\\\\\\
\pi = 1/d &\Longrightarrow \pi = 1/5 = 0.2
\end{aligned}
$$
Therefore we should set the odds such that their implied probability is equal to the true probability of the outcome occurring.

Now what if we are a real bookmaker and actually want to make a profit (our overround)? Lets say on average we want to make 5% of the wagers we collect so $E[Profit] = 0.05W$. 
$$
\begin{aligned}
0.05 \cdot W &= W - 0.2 \cdot W \cdot d \\\\\\
0.05 &= 1 - 0.2 \cdot d \\\\\\
d &= (1 - 0.05)/0.2 \\\\\\
d &= 4.75 \\\\\\
\\\\\\
\pi = 1/d &\Longrightarrow \pi = 1/4.75 = 0.21
\end{aligned}
$$
We can see that if we want to make a profit on average the implied probability of our odds has to be greater than the true probability. 

To summarise, implied probability is made up of the true probability and the overround. In theory it's possible to remove the overround and get a confident estimate of the bookmaker's belief in the true probability.

Hopefully you now have more of an intuition behind the concept of implied probability. There's plenty more to unpack here such as the different methods for removing the overround and how to use all this information to get an edge over the bookmakers. Hope to cover these in later posts!