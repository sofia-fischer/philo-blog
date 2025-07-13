---
title: "Bitemporal Data: Timetravel your Data"

date: 2025-07-10T10:20:44+02:00

draft: false

description: Bitemporal data is a way to store data that has two time dimensions - the actual time and the record time.

tags: [ "Python", "Development" ]
---

{{< lead >}}
Storing historic data becomes more complex if the historic data needs might also change over time and if those changes
should be accessible. Bitemporal data is a way to store data that has two time dimensions: the actual time and the
record time.
{{< /lead >}}

## Understanding the concept of Bitemporal Data?

### Temporal Data

Temporal data is data modelling historic changes of something. Most data in modern dataases is temporal data just by
storing a `created_at`. But intentionally temporal data is often implemented by a model having a `actual_from` and
`actual_to` properties (or `valid_to`, `active_to`, `ended_at` ...), which correspond to non-overlapping time periods.

Some examples for this:

* Price tracking over time: The cupcake did cost 3,55€ in the last week, but this week the price was increased to 3,75€,
  and on monday there will be a sale and it will only cost 3€
* library book rental history: The book was rented by Ari from 01.03 until 01.04, nobody took it for a month, then Noa
  took it and still has it.
* Chameleon color change over time: The color was green yesterday, and today I saw the the color change from green to
  magenta.

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
seen and recorded.

Keeping those reports can be necessary to proof what knowledge was present in a point in time, or just to
understand what has happened when an error occurred, or to being able to react to unreliable data that might be
canceled later.

This adds a new time dimension to the existing model: the point in time in which the actual information was recorded,
and the point in time in which the recorded time was overwritten by more recent data. The naming of those properties
vary (because naming is hard), but a common combination are `actual_from` and `recorded_at` coined by Martin
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

The query to find the actual color would look like `SELECT color FROM chameleon_colors WHERE ` XXXXX AI help ^^

## Using Bitemporal Data

## Collision Handling on Periodical Data

{{< mermaid >}}
gantt
    title Relationships between two periods.
    dateFormat YYYY-MM-DD
    section A before B
        A    :A, 2025-07-01, 3d
        B    :3d
    section A meets B
        A    :2025-07-01, 3d
        B    :3d
    section A overlaps B
        A    :2025-07-01, 3d
        B    :3d
    section A equals B
        A    :2025-07-01, 3d
        B    :3d
    section A starts B
        A    :2025-07-01, 3d
        B    :3d
    section A finishes B
        A    :2025-07-01, 3d
        B    :3d
    section A during B
        A    :2025-07-01, 3d
        B    :3d

{{< /mermaid >}}


* Only trusting the latest information
* collission handling
* handling empty or unknown periods
* database constraining
* Against database normalisation and growing tables

















