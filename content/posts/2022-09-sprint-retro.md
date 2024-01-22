---
title: "Improving Retros from a Devs Perspective"

date: 2022-10-10T14:20:44+02:00

draft: false

description: "As a developer, most of the meetings I join I either want to talk about code, or I am asking myself why I
joined the meeting, and if I would not be more productive writing code. Retrospectives are an exception. I love
retrospectives. I enjoy the feeling of improvement after a retro, I like the open communication of retros, and I like
the feeling of being heard."

tags: [ "Agile" ]
---

{{< lead >}}
As a developer, most of the meetings I join I either want to talk about code, or I am asking myself why I joined the
meeting, and if I would not be more productive writing code. Retrospectives are an exception. I love retrospectives. I
enjoy the feeling of improvement after a retro, I like the open communication of retros, and I like the feeling of
being heard.
{{< /lead >}}

## Retros by Scrum Definition

A Retrospective is a meeting that is focused around improving the processes in and around a team. It often happens after
the sprint and addresses stumble stones that happened during the sprint. It's neither about blaming people nor about
whining, it's about improving productivity, effectiveness, and developer happiness.
In the Retrospectives I attended, common discussion topics include how much can business interrupt in the sprint; how
should communication happen between teams, how is the team defining definition of done / ready / production ready; or
what meetings should be required for developers or maybe need time changes [^agileDefinition].

{{< alert >}} During the Sprint Retrospective, the team discusses: \
What went well in the Sprint \
What could be improved \
What will we commit improving in the next Sprint

{{< /alert >}}

[^agileDefinition]: Stolen from [Scrum.org](https://www.agilealliance.org/glossary/retrospective/)

### Little dangers of Retros

Retrospectives come with some dangers. They are often all-hand-meetings, which means if they become useless often two
working hours per developer and scrum master are wasted. The developer happiness wasted by frustrating meetings is
what bugs me personally, but for some managers, it is easier to argue with the cost of a meeting. The hours of meeting,
times the number of people, times the hourly rate of everybody quickly ends up in a number big enough that even the
cost-focused managers value the time of team members.

To keep the Retrospectives useful, they need to be goal-oriented, honest, and what I would call in german "kurzweilig" -
which translates to feeling quick and amusing. More agile definition trained people have written posts on how important
it is to make it a safe space for the team to talk about what is not working; and how it is important to have measurable
changes that have an impact on the team. What I was missing in the retrospectives I attended was a bit of the fun part.

## Retrospectives Gamification

I went to some retrospectives where the team was asked to display their mood using a weather frog in the best case,
or to write down their problems on sticky notes and then put them on the same three colored miro rectangles every sprint
in the worst case. It's not bad... it's just boring.

For my current team, I started to make the retrospectives a bit more fun. I started with different themes, and people
enjoyed it. People started to ask how I created them, what my references where, and how I would come up with the ideas -
so this post will be both an idea for interested, a guide for creators, <strike> and a collection of themes for those
who just want ready to use themes </strike> (never mind that; explained in the last paragraph).

### Using themes for asking different questions

#### Start, Stop, Keep

The most commonly described Retro Questions are **What should we start to do?**, **What should we stop doing?**, **What
should we keep doing?**.
Those questions have their reasons and fulfill what a Retrospective wants to achieve. However, asking every time the
same
questions in my experience leads to the same answers. Although Scrum Masters would appreciate it, most Dev Teams do not
collect various points to improve throughout the sprint, and then discuss them in the retro. Instead, they discuss what
comes to their mind the moment they are asked - This is not blaming, it's mostly self-observation.

The following Questions are more or less rephrasing these base questions of Retrospectives. Asking in different ways
can lead to new answers and also can give each Retro a theme by itself, a team that is happy in the current setting
might benefit more from talking about what tools or practices could be added, while a fresh team might focus on
well-being.

All upcoming ideas are focused on the idea of sharing a view (live or virtual) and placing post-it like notes on a
board.

#### Finding good and bad practices

When evaluating practices it can be helpful to guide the team using one (or multiple) axes. Depending on the Situation
just asking for good or bad practices can be enough, but e.g. after a troubled sprint it might be helpful to ask for
specific practices for prevention or future firefighting; if the Team is looking for new technology a cloud or tree can
be used to group discussions in different branches of topics; and if working with existing metrics those metrics can be
used to place member opinions; during special occasions just rephrasing the question can be fun - like asking for the
best tricks or treats in Halloween themed retro.

![Finding good and bad practices](/images/2022-10-retro-1.png)

#### Communicating Doubts

Although this might be included in the bad practices, often enough precisely asking for problems and doubts can reveal
more problems and encourage a discussion in the team. To support the discussion in the Retrospective, different axes and
designs can again add value compared to the (still valid and useful) word cloud.
Some examples are adding Priorisation to encourage the team to not only add topics that need improvements but also to
rank them on their urgency; if the topics that need change are already known, a heatmap can be visualised what the
important pain points are; on the other hand to discover new improvement points a categorisation can refine and increase
the results; last but not least sometimes negating the question can lead to a different point of view and again reveal
unknown concerns.

![Communicating Doubts](/images/2022-10-retro-2.png)

#### Finding Vision and Celebrating Success

Celebrations are often left out, but I enjoy the idea of celebrating the little learning we found to
communicate them and to encourage going deep to understand the framework, the domain, or the customer better.
For developers who don't enjoy bragging in the daily about what they learned, dedicated badges can be a nice starting
point. (I would award code, features, ideas, or situations instead of people).
Regarding Vision and goals, of course the word cloud is again a valid idea (the theme example of dishes as above can be
reused - "what spices are missing in our success / code recipe?"). But it's again more effective to also rate the
improvement ideas by the time frame in which an idea adds value to the company / team / codebase.
If the main goal is to first come up with any ideas, a Venn Diagram can be helpful to identify differences between the
team goals (like a well tested code base) and the business goals (like new features now).

![Finding Vision and Value](/images/2022-10-retro-3.png)

#### Mood Check

Last but not least, a mood check can be helpful to identify the general feeling of the team and can be just fun.
Any spectrum of "feeling alive?" can give a quick overview of the individual mood; if sticking your note in the same
place every time became a habit, it can be helpful to move the "feeling good" spot on an axis to the center.
Also, a fun exercise is to give a theme and ask for one word to describe the last sprint.
Similar to the other questions, of course categorisation can again help to discover new problems in the team by
enforcing
questioning some practices in the team.

![Finding Vision and Value](/images/2022-10-retro-4.png)

## Special Retros (updated 29.12.2023)

From time to time, a special retro can provide an overview of the team's long-term state, can be used to celebrate
very big milestones, or fill retros which will presumably not be very productive.

### Timeline Retros

Perfect for pre new year retrospectives, or for retrospectives after finishing a great milestone.

First Step - Reconstruct the timeline: A timeline over a selected time frame (e.g. the last half year) is provided.
Additionally, a set of categories (new Team member started, achievement unlocked, new technology introduced, ...) or
some timeline distinctions (team events, company events, ...) may be provided as help.
In our team, it was helpful to do this step as discussion instead of individual work, as already in this step the team
discovered that the team does not remember achievements and want to celebrate them more.

I already find this step very valuable, and the next step depends on the team capabilities to communicate their
feelings. Not all teams are comfortable sharing their feelings, but if they are, the next step can provide nice
insides.

Second Step - Match the teams feelings: The team is asked to place their feelings on the timeline.
This can be used to discuss what events changed the team's mood, and what events can maybe celebrated or discussed in
future.

![Timeline Retro](/images/2023-12-retro-5.png)

## Collection of Themes

The idea of this blog was to publish my themes. I made themes like:

- Pokemon: What was your hardest battle? On a scale of "Developer fainted" to "Developer had a critical hit" - how was
  the sprint? ...
- Don't Starve (the video game): What is your sanity level after the sprint? What monsters scared you the most? ...
- Pen and Paper: What was your hardest dungeon? What was your best item? ...
- Beer pong: What was your best trickshot? ...
- ... (an more, this list will not be updated) [^themes]

BUT, I don't feel comfortable publishing them because I am scared of copyright problems. I respect the work of the
different artist, I am sure if I would ask them I could use the pictures, but honestly, I am too lazy for that as well.
So take this advice:

> Be creative, use cool themes, make your developers smile at your themes - everything is
> allowed. Steal the questions and setups from this and other blogs, and color it with whatever your devs enjoy;
> when in doubt, add a unicorn 🦄.

[^themes]: For inspiration use
this [Set of Themes with questions and online tools](https://www.scrum.org/resources/blog/retrospective-ideas)

Happy Coding :) 
