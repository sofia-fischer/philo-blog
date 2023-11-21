---
title: "Using data for Sprint Planning"

date: 2023-11-21T14:20:44+02:00

draft: false

description: "It is better to be vaguely right than exactly wrong. - Carveth Read. While the trend goes
  in a direction to put a metric on everything to drive decisions, most teams I have worked with are still in the
  beginning of this journey. Here is a collection on Information on what, how, and why to collect Data for project planning"

tags: [ "Agile", "Team Communication" ]
---

{{< lead >}}
"It is better to be vaguely right than exactly wrong." - Carveth Read. While the trend goes
in a direction to put a metric on everything to drive decisions, most teams I have worked with are still in the
beginning of this journey.
{{< /lead >}}
[^carveth]
[^carveth]: [Logic - DEDUCTIVE AND INDUCTIVE](https://www.gutenberg.org/files/18440/18440-h/18440-h.html)

## Using Data to Ignite Action

In one of my favorite talks from DevOpsDays [^devopsdays] Julie Starling is talking here about using data to drive
conversations.
[^devopsdays]: [DevOpsDays Amsterdam 2023](https://www.youtube.com/watch?v=91l3rtL81xs)

On of the key takeaways for my was the Idea of Probabilistic Forecasts. This means using past data to make a prediction
about the future with the awareness that the prediction is not 100% accurate, focusing on a probability in a range.
For example "There is a 80% chance of delivering 10 or more Story Points this Sprint" (How much will we do?);
or "There is a 90% chance of finishing 10 Story Points in the next 14 Days or less" (When will we get it?).

### Monte Carlo Method

Monte Carlo Method: Builds a model of possible results by using the Law of greater
Numbers; OR Simulations to calculate the probability of a range of outcomes, which somewhat if we run a
Simulation based on our last 10 Sprints, x% of the time we would have delivered a minimum of y Story Points in time.
The accuracy of the prediction increases with the increased number of inputs - although in a development environment
with experiments, changes in tech stacks, or changes in team composition, less inputs might be sometimes more accurate.

{{< alert "circle-info" >}}
Monte Carlo might not include correct risk dependencies. If one ticket fails, dependent might or might not fail too.
{{</alert >}}

### Using Data to Drive Conversations

Julie uses Monte Carlo Simulations multiple times throughout the Sprint, to get a better and better prediction - and to
react at the earliest possible time. The moment the probability of delivering the minimum Story Points in time drops, or
the expected date to finish all work items is after the deadline, there is a need for a conversation.
This Conversation might include a change of expectations or a change of scope.

## The Flaw of Averages (by Sam L. Savage)

This book is a great starting point to understand why Averages are not the best metric to plan actions.  [^flaws]
[^flaws]: [Flaw Of Averages](https://www.flawofaverages.com/foa-overview)

Plans based on average assumptions are wrong on average. Every developer knows the struggle to explain to PO that 10
Tickets with all the same estimation of one week will only be on average be delivered in a week, and therefor
behind schedule half of the time.

### The weak and strong form of the Flaw of Averages

The weak form of the Flaw of Averages states is forecasting a result based on a single number instead of the
distribution
of outcomes. One kinda german example for this would looking at the average win of a lottery without considering the
average cost or the probability distribution.

The baseline to avoid this is "View uncertainty as a shape, not a number." (Normal distribution, even distribution, ...)

The strong form of the Flaw of Averages states that the average inputs do not equal the average outputs. The output of
the average team is not equal to average output of all teams.

### The seven deadly sins of Averages

* The average often does not exists (like the 1.5 child people have)
* The average task length is not the average project length
* Diversification works for projects management: If you add more independent tasks, the form of the distribution
  histogram will approach a bell curve.
* Be clear if your risk depends on restriction (how many people can work on a task) or on opportunity (how much will
  performance increase from refactor).
* Optionality - can you remove costs in case of losses?
* Cost of average demand is not the average cost.
* Things may happen by chance => we are just doing hypothesis testing.

{{< alert "circle-info" >}} **Flaws of Extremes**: Budgeting for risks becomes exponentially expensive.
{{</alert >}}

## Current State of Error

After this theory, I am still in the process of implementing this in my team. Moving away from the simple
calculation of Averages to complex modelling while spending enough time in this to make it a valid experiment, and not
falling for sunk cost fallacy or spending more time on it than the team would benefit from it.

I wish I could write more about how this changed my team, or how we implemented it; but this is my current state of
error.

Keep Coding :) 
