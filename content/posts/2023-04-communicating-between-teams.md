---
title: "Communication between different teams working on the same codebase"

date: 2023-04-16T14:20:44+02:00

draft: false

description: "Effective communication is essential in software development. As per Conway's Law, the structure and
architecture of a software system are influenced by the communication patterns and structures within the organization. "

tags: ["Agile", "DevOps"]
---

{{< lead >}}
Effective communication is essential in software development. As per Conway's Law, the structure and architecture of a
software system are influenced by the communication patterns and structures within the organization.
{{< /lead >}}

## Conways Law

{{< alert "circle-info" >}} **Conways Law**:
Any organization that designs a system (defined broadly) will produce a design whose structure is a copy of the
organization's communication structure. [^conwaysLaw]
{{< /alert >}}

[^conwaysLaw]: [Conway's Law](http://www.melconway.com/Home/Committees_Paper.html)

Conway's Law means that the communication structures and patterns within the team will impact the design and
architecture of the software system a set of Developer Teams is developing.
If the team is structured in a way that promotes collaboration and communication between different members and
departments, the resulting software system will likely be well-structured and modular, with clear interfaces between
different components.
On the other hand, if the team is siloed and communication is poor, the software system may end up being poorly
organized and difficult to maintain.
Silos can occur when teams are organized around a specific product and do not have the chance to collaborate with other
teams or consider reuse of existing work.

## Ways to improve communication

There are many ways to improve the communication between teams, some will be outlined here.

![Talk to the Corgi Butt](/images/2023-04-talk.png)


### Architecture Decision Records

Tests, comments, and human readable code are in my experience the most read and used documentation.
But still, there are situations in which the way the code is written only makes sense in the context in which the
decision was made.
Often enough, that bad looking class has a reason to exists in that way - and even if the explanation is "because of
historic reasons", it something in a lot of codebases has to be communicated verbally.
Especially in cases, where multiple teams work on the same code base this can be a problem - that is why Architecture
Decisn Records (ADR) can fill that communication gap.

**Hype or Established?** The concept of ADRs was coined in 2011 [^netflix], was added in the thoughtworks tech
radar in 2016 [^techRadar], and is now in usage in multiple tech companies (often if the teams are very independent).
The tools on the other hand are often open source, sometimes still working, and rarely maintained well [^git].
My personal two cents are: Architecture Decision Records are established, but the tools are often more hyped that
practical.

[^git]: [ADR Tools](https://adr.github.io/)
[^techRadar]: [Thoughtworks Tech Radar](https://www.thoughtworks.com/en-us/radar/techniques/lightweight-architecture-decision-records)
[^netflix]: [Michael Nygard: Architecture Decision Records](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)

Example of an ADR:

```markdown
# Use Markdown for Architecture Decision Records

## Context and Problem Statement

We want to record architectural decisions made in this project. The following requirements apply:

- The format should be human readable and easy to write.
- The files should be inside the code base, such that a new decision can be made using a pull request.
- The format should enable references to older decisions or files in the code base.

Some established solutions:

* [MADR](https://adr.github.io/madr/) - Some simple Markdown solution
* Michael Nygard's template [^techRadar] – Markdown with Status and Consequences
* The Y-Statements - "we decided for XXX and against ZZZ to achieve A and B, accepting that C".
* Formless – No conventions for file format and structure

## Decision Outcome

The benefits of Michael Nygard's template are the Consequences, so a section to update information on the decision, e.g.
by now a new feature has replaced this decision, but this one customer still needs it, so it is marked deprecated.
This contradicts the idea that these files a immutable, but here I am still coding PHP so what do I know.

## Status

I wrote a blog post, will have hold a presentation in my current company, and see what happens.

## Consequences

//
```

### KPIs as a common goal

To fight Silos, one option is to give teams common, meaningful KPIs and missions that contribute towards larger
goals, encouraging collaboration and avoiding the siloing of teams.
Communication is also key to breaking down silos, and teams should seek opportunities to work together and learn from
each other's areas of expertise [^podcast].

[^podcast]: [Becoming a Great Engineering Manager and Balancing Synchronous and Asynchronous Work - InfoQ Podcast](https://www.infoq.com/podcasts/balancing-synchronous-asynchronous-work/)

### Team Structure

Silos can develop in software development when teams or departments become isolated and focused only on their own goals
and objectives, without considering how their work impacts the rest of the organization.
This can lead to a lack of collaboration, poor communication, and a fragmented approach to software development.

* Shared accountability: Cross-functional teams are accountable for the success of the project as a whole, not just
  their individual tasks.
* Improved communication: Cross-functional teams encourage open communication between team members from different
  disciplines, which can help to break down silos by promoting a culture of knowledge sharing and collaboration.
* Shared knowledge: Cross-functional teams bring together different areas of expertise, which can help to reduce silos
  by sharing knowledge and skills across the team.
* Faster decision-making: Cross-functional teams can make faster decisions as there is no need to wait for approval from
  different departments.

Also switching around the teams can improve communication and collaboration, as well as knowledge sharing.

### Common Meetings

A possible Agenda may vary from meeting to meeting, but the goal is to have a common meeting where all teams can
participate and exchange knowledge.

* **Latest Features**: A meeting in which each team presents the latest features they have implemented, including the
  added dependencies or patterns.
* **Latest Wins**: Talking about patterns which have proven useful, Code styles that made things easier to read, or
  anything else that has been a win for the team and can be a win for others.
* **Latest Fails**: Having a shared Post Mortem of a failed feature or a failed deployment can help to avoid the same
  mistakes in the future.
* **New Ideas**: A meeting in which a new Idea is pitched to be discussed and feedback is given.
* **Social**: The goal of such a meeting may be nothing more than social interaction, just having a pub quiz as only
  agenda point can
  be relaxing from time to time.

## Conclusion

There are ways to improve Team communication, and the way the communication is organized, how hygienic and structured it
is, can have a huge impact on the software system that is being developed. I would not dare to enforce long, daily or
weekly meetings on developers who prefer sitting in their cellar and coding, because communication does not need to be a
meeting, nor a formal setup with 50 people. 

Happy communicating!
