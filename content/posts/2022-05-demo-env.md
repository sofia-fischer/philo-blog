---
title: "Demo Environments and what I learned from implementing one"

date: 2022-05-11T20:36:22+02:00

draft: false

description: "I got the task to implement a Demo environment, learned something about Laravel Factories and the usage of
an environment to give possible customers / investors a taste of your product and the developers to find response time /
query problems and UX bugs"

tags: ["Development", "DevOps", "Laravel"]
---

{{< lead >}} I got the task to implement a Demo environment, learned something about Laravel Factories and the usage of
an environment to give possible customers / investors a taste of your product and the developers to find response time /
query problems and UX bugs {{< /lead >}}

# A "Demo" Feature Request

This card was proposed in a sprint planning and sparked a discussion around multiple problems and ideas.

> As a future Analytics-Component User I want to see a version of the Analytics-Component fully functional with
> generated data, so that I can see how the page would look like, before I buy the Analytics Component

First, the ideas: this company sold a software platform with one of its components being a set of graphs, statistics,
and informative texts to display the usage of the other platform features. The Analytics Component was not meant for
intern analytics, but a feature set for business customers. Allowing business customers to play around with such a page
before making decisions is a nice to have feature - who dislikes demos? A nice demo page is reachable for the interested
customer, can't break - even if the customer has no idea what they are doing, and should display as many features as
possible accurately, up-to-date, and in sense-full context.

Then, the discussion: We sure will not re-build the multi-page Analytics Component with some mocked graphs to only
forget about updating it whenever we add a page to the real product. After some discussion we want to generate (only the
needed) data to display all graphs and information correctly, but sure don't want any of it to be in our production
database. So we decided the best thing to do is to set up a demo environment that became part of our pipelines and would
receive the same features while holding the maximum workload one customer could cause. The demo account would be
reachable to potential customers by offering the demo user credentials and link to the environment, so the future
customer could play around with the page without breaking anything.

![Trueman Show Reference. "Show Customers, Show Investors, Test UX, Test Performance"](/images/2022-05-demo.png)

## Implementation

Setting up a cost-efficient small server, building some pipelines, and branching a new 'demo' branch from master. Before
starting the implementation I would like to set some constraints on the task. The Analytics Component could was
displaying data starting from yesterday, and keep historical data up to one year. The data required was a mix of
multiple models - a great thanks to the business for allowing the dev team to refactor most of the respective data to an
Event-Sourced pattern some weeks ago. The Component should work and display data every day, so there had to be a job to
generate new data every night. So what I build was:

* A Command triggered by every deployment to re-generate the data if needed, e.g. if a feature changed an additional
  data had to be generated
* A Job to run every night (as nobody was relying on the server one slow job would be fine). This job generates new data
  every day, and deletes every data that is older than a year.

### Laravel Usage of Factories

{{< alert "circle-info" >}} **Laravel Learning**: Cascading Factories {{< /alert >}}

Factories are a great way to generate data. One problem I run into was writing a factory that could also generate the
corresponding EventS-ource Model. Event Sourcing in one sentence describes a pattern in which the changes of a state are
stored in a database. Imagine we have Users who can collect Experience Points by playing Games. Instead of increasing a
column in the `users` table, or summing up the score column of the `games` table (because maybe there are more ways to
earn points), we create a table `experiences` which holds the user who earned points, the cause of points and the number
of points earned. This can be a great pattern if you plan on having some analytics (which then only need to query one
table), or want to leverage the "event" part of the pattern and have multiple background/ async jobs happening whenever
the state is changing.

The corresponding factory to generate games with experiences would be:

```php
class GameFactory extends Factory
{
    protected $model = Game::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'score'   =>  random_int(0, 100),
        ];
    }

    public function withExperience(): self
    {
        return $this->afterCreating(fn (Game $game) => 
            Experience::factory()->create([
                'game_id'    => $game->id, 
                'user_id'    => $game->user_id,
                'created_at' => $game->created_at,
                'updated_at' => $game->updated_at,
            ]));
    }
}
```

And it could be used like this:

```php
$game = Game::factory()->withExperience()->create();
```

### About generating data with context

Generating random data is tricky. There are some learnings I want to share while I wrote the job:

* Whenever it makes sense, after generating a bunch of models I invalidated and soft-deleted a subset of those. This
  helped to get a realistic view and I hoped I could spot a bug if did so.
* When working with data created every day I had a look at the average user - in this case people were more active on
  weekdays compared to weekends. This is no simulation, I avoided holidays or anything, but a small line with the
  integrated Carbon function was easy enough to give some realistic flow in the
  data ``` $date->isWeekend() ? random_int(2, 15) : random_int(45, 101) ```
* The Pages of the Analytics Component were my guide on how to vary the data - when the UX Designer worked on this, what
  data did they or the business expect? If there was a ranking I decided in the implementation which subset of models
  would be used more often to from relations to have live-like rankings.
* Keep it simple: Whenever there was a model that was not in any way needed to display the Analytics Component - I would
  not seed it.

## Using the Demo Env as Stress Test and Bug Revealer

Some writing of colorful text on dark background later we deployed and watched the system taking disturbing 16 seconds
to load some pages. Did I mention that the company was a Start-Up without a customer who had been causing data of that
size for a year? The product owner opened a fresh pack of post-its to note down every end-point that required query
optimisation as we developers got shameful credit for the not scalable system we had built. Additionally, not all graphs
that we did imagine worked out with that many data points, while some other inspired completely new ways do structure
the data.

{{< alert "circle-info" >}} **Development Process Learning**: Having a demo environment with generated data can point
out response time problems, visualisation problems and be an inspiring point of view for UX and Code Development {{<
/alert >}}

The query optimisation was not too hard, avoid over-fetching, let SQL do whatever it can to faster than PHP, and use
eager loading whenever possible. The big learning of this experience was not how I optimised the queries, but how the
bottleneck was discovered. The reason I write this article is, that I recommend any high aiming Start Up to try this.
Not only is it a nice feature to present your investors a view on your page "if people would use it", but also it can
uncover some bottlenecks you mind not have thought of in an early stage but would regret in case of that exponential
growth the business owner is promising next month. 

