---
title: "Bitemporal Data: Timetravel your Data"

date: 2025-07-10T10:20:44+02:00

draft: false

description: Bitemporal data is a way to store data that has two time dimensions - the actual time and the record time.

tags: [ "Python", "Development" ]
---

{{< lead >}}
Storing historic data becomes more complex if the historic data changes over time and if those changes
should be accessible. Bitemporal data is a way to store data that has two time dimensions: the actual time and the
record time.
{{< /lead >}}

## From Temporal Data to Bitemporal State Data

### Temporal Data

Temporal data is data modelling historic changes of something. Most data in modern dataases is temporal data just by
storing a `created_at`. But intentionally temporal data is often implemented by a model having a `actual_from` and
`actual_to` properties (or `valid_to`, `active_to`, `ended_at` ...), which correspond to non-overlapping time periods.

Some examples for this:

* Price tracking over time: The cupcake did cost 3,55€ in the last week, but this week the price was increased to 3,75€,
  and on monday there will be a sale and it will only cost 3€
* library book rental history: The book was rented by Ari from 01.03 until 01.04, nobody took it for a month, then Noa
  took it and still has it.
* Chameleon color change over time: The color was green yesterday, and today the color changed from green to magenta.

From a technical point of view, this enables a nice implementation; a database constrain can ensure that there are no
overlapping time periods.

```python
import datetime


class ChameleonColor:
    actual_from: datetime.datetime
    actual_to: datetime.datetime | None
    color: str
```

### Non linear data reporting

The moment the data becomes available not in a linear way, the simple temporal data model becomes more complex to
handle.
What if the information on what color the chameleon has arrives not at the moment it changes, but only as it has been
recorded to the system.

Keeping those reports can be necessary to proof what knowledge was present in a point in time, or just to
understand what has happened when an error occurred, or to being able to react to unreliable data that might be
canceled later.

This adds a new time dimension to the existing model: the point in time in which the actual information was recorded,
and the point in time in which the recorded time was overwritten by more recent data. The naming of those properties
vary (because naming is hard), a common combinations are `actual_from` and `recorded_at` coined by Martin
Fowler [^fowler], `valid_from` and `recorded_at` coined by Richard Snodgrass [^snowdgrass].

[^fowler]: [Martin Fowler on Bitemporal Data](https://martinfowler.com/articles/bitemporal-history.html)
[^snowdgrass]: Developing Time-Oriented Database Applications in SQL (The Morgan Kaufmann Series in Data Management
Systems) by Richard T. Snodgrass

```python
import datetime


class ChameleonColor:
    actual_from: datetime.datetime
    actual_to: datetime.datetime | None
    color: str
    recorded_at: datetime.datetime
    record_overwritten_at: datetime.datetime | None
```

### Understanding Bitemporal Data

**Do we need a `record_overwritten_at`?**

Just looking at a query to retrieve the state of the chameleon at a specific point in time, there is no need to add a
column that just records when a period was overwritten. But to utilize database constraints to ensure that there are no
overlapping time periods in the calculated reality, a `record_overwritten_at` that is `None` for the valid period makes
everything easier.

**How to read bitemporal data?**

Looking at an example of a chameleon that was recorded green at 2025-01-01, then changed to magenta at 2025-01-05, but
the system only recorded the change at 2025-01-09.

| actual_from | actual_to  | color   | recorded_at | record_overwritten_at |
|-------------|------------|---------|-------------|-----------------------|
| 2025-01-01  | NULL       | green   | 2025-01-01  | 2025-01-09            |
| 2025-01-01  | 2025-01-05 | green   | 2025-01-09  | NULL                  |
| 2025-01-05  | NULL       | magenta | 2025-01-09  | NULL                  |

The SQL query to retrieve the current state of the chameleon at 2025-01-07 would look like this and return `magenta`:

```sql
SELECT color
FROM chameleon_color
WHERE actual_from <= '2025-01-07'
  AND (actual_to IS NULL OR actual_to >= '2025-01-07')
  AND (record_overwritten_at IS NULL) LIMIT 1
```

Visually, this can be represented as follows:

```text
- - - - - - - - - - - - - - - -  Point in time imagine we are - now
2025-01-09 ------█|██   magenta
2025-01-09 -█████----   new green period
2025-01-01 -░░░░░░|░░   green, invalidated
                  ↑ Point in time we are looking for at 2025-01-07
```

The SQL query to retrieve the state of the chameleon at a specific point in time (like 2025-01-07) from the perspective
of one day later (2025-01-08) asking effectively "it was 2025-01-07, which color would we think the chameleon had
yesterday?" The SQL query would look something like this and return `green`:

```sql
SELECT color
FROM chameleon_color
WHERE actual_from <= '2025-01-07'
  AND (actual_to IS NULL OR actual_to >= '2025-01-07')
  AND recorded_at <= '2025-01-08'
  AND (record_overwritten_at IS NULL OR record_overwritten_at >= '2025-01-08')
ORDER BY recorded_at ASC LIMIT 1
```

Visually, this can be represented as follows:

```text
2025-01-09 ------█|██   magenta
2025-01-09 -█████----   new green period
- - - - - - - - - - - - - - - -  Point in time imagine we are at 2025-01-08
2025-01-01 -░░░░░░|░░   green, invalidated
                  ↑ Point in time we are looking for at 2025-01-07
```

Mind that we do not get the "real" state of the chameleon at 2025-01-07, but the state as the system thought it was.

**In case of a collision, should we add more rows or update?**

Looking at an example of trying to insert a new period, that should overwrite an existing period:

```text
A ------███-  more recent period
B -███████--  old period
```

We could just split the old period, saving pressures database storage:

```text
A ------███-  more recent period
B -█████----  valid part of old period
B ------░---  invalid part of old period
```

While this works in theory, it is much harder to recalculate the reality of the data at a specific point in time.
What accountants use since centuries to add a new period for to replace invalid old data preserves the history of the
data. Making the rows immutable except for the `record_overwritten_at` column, allows much more trust in the
data ensures no data is lost.

```text
A ------███-  more recent period
B -█████----  valid state old period
B -░░░░░░░--  invalid state of old period
```

**How to insert an period**

An new period is inserted by

* find any collisions with existing periods
* invalidate the existing, older periods by setting their `record_overwritten_at` to the new periods `recorded_at`
* insert new periods to represent the current actual state of the data with `recorded_overwritten_at` set to `NULL`

## Inserting Bitemporal Data

Inserting a new period in chronological order with always open-ended periods is easy: invalidate the existing period,
and create a new "existing" period that ends as the new period starts, and the new period.

But what if finite periods can be inserted in any order? Lets look at this example:

```text
2025-01-05 --█-------  teal
2025-01-04 ------██--  turquoise
- - - - - - - - - -  Point in time magenta is inserted spanning over the whole time
2025-01-02 ██--------  green
2025-01-01 ----█-----  blue

With new data
2025-01-05 --█-------  teal
2025-01-04 ------██--  turquoise
- - - - - - - - -  
2025-01-03 --------█-  magenta 
2025-01-03 ---███----  magenta
2025-01-03 -█--------  magenta
2025-01-03 █---------  green
2025-01-03 -░░░░░░░░-  magenta
- - - - - - - - - 
2025-01-02 ░░--------  green
2025-01-01 ----░-----  blue
```

To insert the magenta period,

* the blue and green periods need to be invalidated, as they are older and colliding with the new period
* the new magenta period needs to be inserted, but invalidated as there are more recent, colliding periods
* a new green period needs to be inserted, because while the green period is partially colliding with the magenta
  period, it started before the magenta period and is still valid until the start of the magenta period.
* a new magenta period needs to be inserted to fill the gap between the green and teal period
* a new magenta period needs to be inserted to fill the gap between the teal and turquoise period
* a new magenta period needs to be inserted for the fraction of the magenta period that lasts longer than the turquoise
  period.

### Types of Collisions (Side Quest)

Following a first thought, I wanted to go by the flow of time and deciding for each period if it is newer or older, and
what insertions or updates need to be performed.

The relationships between two periods can be one out of 13 defined relationships, mathematically defined by James
Allen [^snodgrass]. While periods can be ordered by many things (the length, the start, the end, creation date),
ordering by the start date leaves 7 relationship between each period and the next one.

| Relationship                      | Visualisation                      | Definition          |
|-----------------------------------|------------------------------------|---------------------|
| A before B                        | `A -███------` <br> `B ------███-` | A₂ < B₁             |
| A meets B                         | `A -████-----` <br> `B -----██---` | A₂ = B₁             |
| A overlaps B                      | `A -████-----` <br> `B ----█████-` | A₁ < B₁ AND B₂ < A₂ |
| A equals B                        | `A ---████---` <br> `B ---████---` | A₁ = B₁ AND A₂ = B₂ |
| A starts B                        | `A ---███----` <br> `B ---██████-` | A₁ = B₁ AND A₂ < B₂ |
| A finished by B                   | `A -██████---` <br> `B ------█---` | A₁ < B₁ AND B₂ = A₂ |
| A contains B <br> (B is during A) | `A ---██████-` <br> `B ----███---` | A₁ < B₁ AND B₂ < A₂ |

Out of the 7 relationships, 6 will result in a collision that needs to be handled, and will result in at least two rows
to be touched.
Considering that any in any the 6 relationships, any of the periods can be the newer one, there are 12 cases to handle -
a number of ifs that can quickly grow out of hand.

But looking at the complex example, the solution might be much simpler.

### Handling sets of collisions

Instead of trying to handle each period individually, it is much easier to handle sets of periods that are colliding.

1. The first set ist the set of all periods that are colliding with the new period, but are older and must be
   invalidated.
2. There might be one period that started before the new period started, and was invalidated by the new period.
   It has a fraction that must remain valid until the start of the new period. That fraction needs to be inserted as a
   new valid period.
3. There might be one period that ended after the new period ended, and was invalidated by the new period.
   It has a fraction that must remain valid after the end of the new period. That fraction needs to be inserted as a new
   valid period.
4. Create the new period, valid if there are no newer periods colliding with the new period, otherwise invalid.
5. The last set consists of all periods that are colliding with the new period, but are more recent than the new period.
   For each gab between those periods, a new period needs to be inserted that covers the gap and corresponds to the new
   period.

```python
import datetime


def insert_period(actual_from: datetime.datetime, actual_to: datetime.datetime | None, color: str,
                  recorded_at: datetime.datetime):
    colliding_periods = queries.get_ordered_colliding_valid_periods(actual_from, actual_to)
    colliding_older_periods = [
        period for period in colliding_periods if period.recorded_at <= recorded_at
    ]
    colliding_newer_periods = [
        period for period in colliding_periods if period.recorded_at > recorded_at
    ]

    # 1. invalidate all colliding periods that are older than the new period
    for period in colliding_older_periods:
        if period.recorded_at <= recorded_at:
            period.recorded_overwritten_at = recorded_at
            period.save()

    # 2. check for start fraction of older periods
    if (first_period := colliding_older_periods[0]) and first_period.actual_from < actual_from:
        create_period(
            actual_from == first_period.actual_from,
            actual_to=start,
            color=first_period.color,
            recorded_at=recorded_at)
    # 3. check for end fraction of older periods
    if ((last_period := colliding_older_periods[-1])
            and actual_to is not None
            and (last_period.actual_to is None or last_period.actual_to > actual_to)):
        create_period(
            actual_from=actual_to,
            actual_to=last_period.actual_to,
            color=last_period.color,
            recorded_at=recorded_at)

    # 4. create new period
    maybe_overwriten_at = colliding_newer_periods[0].recorded_at if colliding_newer_periods else None
    create_period(
        actual_from=actual_from,
        actual_to=actual_to,
        color=color,
        recorded_at=recorded_at,
        record_overwritten_at=maybe_overwriten_at)

    # 5. handle gaps between newer periods
    fractions = []
    current_start = actual_from
    for period in colliding_newer_periods:
        if current_start < period.actual_from:
            fractions.append((current_start, period.actual_from))
        if period.actual_to is not None or period.actual_to > actual_to:
            fractions.append((current_start, actual_to))
```

### Bitemporal Databases

These patterns do not feel like most relational database patterns. After some reasearch, I found databases that are
specialised to bitemporal data, like [XTDB](https://github.com/xtdb/xtdb). The database is written in Clojure, and uses
event storage under the hood to handle second dimensions of time [^podcast].
Looking at the pattern, the partial immutability of the data, and the inserting of new periods as new entries, even if
it to update existing data, id displays indeed many similarities to event sourcing. 

[^podcast]: [Clojure Podcast on XTDB](https://podcasts.apple.com/au/podcast/bitemporal-databases-what-they-are-and-why-they/id1687271887?i=1000616019962)

## Some Thoughts on downsides of Bitemporal Data

Looking back at the example, inserting 5 rows for a new single new period is a lot. There is not really a way to
euphemise an algorithm that will worst case insert n + 1 rows for a new record, with n being the number of existing
records.
Tables of this bitemporal state data can grow very large, and the database will need to handle a lot of rows.
The patterns discussed here are not trivial, and do not match what at least I learned in university about normalized
databases.

But looking at alternatives; updating the rows and then handling all the case of overlapping periods will result in
an even more complex algorithm, and will provide less trust in the data. Also, this concept of bitemporal data is not
new, some sources I found date back to 2000, and there are many resources to find on the topic. Having the need for
bitemporal data, and trying to optimize for storage consumption, is a trade-off that will cost in readability,
complexity, and reasearchability of the used patterns - if you think otherwise I would be happy to hear your thoughts!

## Conclusion

Bitemporal data is always complex to wrap around.
The amount of articles and resources on this topic is extensive, and I did read through many of posts,
one book, and one podcasts to understand some more granular details of the patterns. They all use different
visualizations, often different namings, with mostly the same approaches to the problem. So while I am confident that
the approach I presented here is one proven way to handle bitemporal data.

The main inspiration for this article was Simeon, who phrased it as "You understand bitemporal data,
until you don't. And when you need it, you understand it again". Big thanks for the inspiration!

This article, as all my public learnings, is my way to understand things, and hopefully have an easy time to
re-understand the concepts and patterns.

Happy coding :)
