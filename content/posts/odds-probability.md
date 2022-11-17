---
title: "Calculating odds with probability theory in order to make a profit"
date: 2022-11-16T18:00:00+00:00
tags: ["probability", "sports-betting"]
---

When looking at sports betting from a mathematical perspective, one interesting question is where does probability theory come in when calculating odds? And can it help a bookmaker increase their chances of making a profit? I'm going to run through a simple approach to setting odds with an appreciation for the stochastic nature of sports.

Disclaimer - this content isn't backed by any real experience of what goes on behind the scenes at bookmakers. It is an attempt at a sensible approach to do calculate odds using probability theory. 

And for the purpose of simplicity, I'm going to use decimal odds.

> **How do decimal odds work?**\
> With decimal odds of $2$, for every £1 you wager you receive a full payout of £2. To convert fractional odds to decimal odds, you convert the fraction to decimal and add 1 e.g. fractional odds of $7/2$ are $4.5$ as decimal odds: 
> $$7/2 + 1 = 3.5 + 1 = 4.5$$

Our goal is to choose odds that will make us a profit. Profit in this space is random so we can represent this as a random variable[^1] and compute its expected value[^2].
\\[
\begin{aligned}
E[Profit] &= E[Wagers] - E[Payouts] \\\\\\
&= W - P(O) \cdot W \cdot d
\end{aligned}
\\]
To convince you of this formula:
- Our expected profit will be the amount of money we receive subtracted by the amount of money we pay out.
- Our expected wagers (or the amount of money we receive) will always be the sum of the wagers.
- If the outcome does occur we expect to payout our odds multiplied by the sum of the wagers we receive and this will occur with probability $P(O)$.

Lets say that we're offering odds on Liverpool beating Man City and we believe that this has a 20% likelihood of occurring so $P(O) = 0.2$. As an experiment, we want to compute the odds that will have us break even on average:
$$
\begin{aligned}
0 &= W - 0.2 \cdot W \cdot d \\\\\\
0 &= 1 - 0.2 \cdot d \\\\\\
d &= 1/0.2 \\\\\\
d &= 5 \\\\\\
\end{aligned}
$$
Now what if we decide that we want to make a profit equal to 5% of the wagers we receive:
$$
\begin{aligned}
0.05 \cdot W &= W - 0.2 \cdot W \cdot d \\\\\\
0.05 &= 1 - 0.2 \cdot d \\\\\\
d &= (1 - 0.05)/0.2 \\\\\\
d &= 4.75 \\\\\\
\end{aligned}
$$
You can see now our odds are lower - it makes sense right? If we want to make more of a profit we reduce the amount we pay out. We can look at this another way using the concept of implied probability.

> Implied probability $p_{imp}$ is the probability of an outcome implied by odds offered on that outcome.
> $$p_{imp} = 1/d$$ 
> Where $d$ represents the decimal odds for a single outcome of an event.

When $d = 5$:
$$
p_{imp} = 1/5 = 0.2 \\\\\\
$$

When $d = 4.75$:
$$
p_{imp} = 1/4.75 = 0.21 \\\\\\
$$

We can see that when we want to break even on average, our implied probability is equal to the true probability. We can also infer that the larger the implied probability, the more positive the expected profit. The difference between these values is called the overround[^3] and here we've proved that we can break down the implied probability into the true probability and the overround (the bookmaker's profit margin).

To summarise, when setting odds on an event, we can work backwards from the profit we want to achieve using probability theory. This approach also shows where the overround comes from in implied probability.

There's undoubtedly a lot that goes into setting odds as a bookmaker but I believe this is one of the fundamental ideas. It's also interesting to think about how we can use the concept of implied probability to build a mathematical strategy towards betting (hint: this can include removing the overround). Hope to do a deeper dive in a future post!

[^1]: http://www.stat.yale.edu/Courses/1997-98/101/ranvar.htm
[^2]: https://www.probabilitycourse.com/chapter3/3_2_2_expectation.php
[^3]: https://www.timeform.com/betting/advanced/overround-explained
