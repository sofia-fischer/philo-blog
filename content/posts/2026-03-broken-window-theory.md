---
title: "Overcoming Broken Window Theory (also in Software Engineering)"

date: 2026-03-25T12:20:44+02:00

draft: false

description: "Some lightheaded quotes of broken window theory hunted me down a rabbit hole about its history and how 
it is still used as metaphor in software engineering."

tags: [ "Code Quality", "Society" ]

---

{{< lead >}}
Some lightheaded quotes of broken window theory hunted me down a rabbit hole about its history and how it is still used
as metaphor in software engineering.
{{< /lead >}}

{{< alert "circle-info" >}}
TLDR: The broken windows theory is heavily disputed if not outright disproven. Don't use it for Software Engineering.
{{< /alert >}}

## Broken Window theory - Idea, Social Impact, and Dispute

The core idea was that signs of disorder (broken windows, litter, ...) in a neighborhood are signs of neglect,
and neglected communities invite more serious crime.

### 1982: The first broken Window

An article is published in The Atlantic, proposing the metaphor that a building that has one broken window will soon
have many broken windows. This image is then projected on communities. Disorder in a neighborhood, may it be
physical litter (or broken windows) or socially perceived disorder like drunks, makes residents feel unsafe, they stay
inside, the informal social control collapses and serious crime is rising.

The only provided evidence for this was a study that showed that foot-patrol officers could increase the _feeling_
of safety, although crime rates were not affected. They distinguished between the police role as law enforcers (actually
catching criminals) and order managers (ensuring peace in public spaces) [^atlantic].

[^atlantic]: ["Broken Windows"](https://www.theatlantic.com/magazine/archive/1982/03/broken-windows/304465/) by James
Wilson, George Kelling, The Atlantic, 1982

### 1994 Zero Tolerance Policy - 2002 Stop and Frisk

The given article could have been interpreted as
_**Investing in neighbourhoods, fixing buildings and cleaning the areas,
empowers those neighborhoods, and people will claim public spaces, and crime rates will decrease**_. But it wasn't.

The New York City Police started "Zero Tolerance Policy Introduced" with Mayor Rudy Giuliani and Police Commissioner
William Bratton leading the idea. This meant increased arrests for even small crimes like spraying graffiti or selling
cigarettes, hoping that punishing even the smallest acts of disorder would also reduce serious crimes. The crime
rate was falling and the media was amazed [^bratton].

[^bratton]: [William Bratton Wikipedia](https://en.wikipedia.org/wiki/William_Bratton)

Looking at the crime rates retrospectively, the famous 1990's drop in crime in NYC already started dropping
before the Zero Tolerance Policing took effect. Comparing the crime numbers to Los Angeles, a city that did not
follow a zero tolerance policing strategy, a similar drop in crime can be observed. This might have had other social
reasons
like economic growth or the end of the Crack Epidemic or something else. Meanwhile, crime decrease complaints of police
misconduct spiked by 60% [^hidden_brains].

[^hidden_brains]: [Hidden Brains Podcast](https://podcasts.apple.com/bm/podcast/episode-50-broken-windows/id1028908750?i=1000377362206)

![Crime Rate 1950-2020 NYC vs LA](/images/2026-03-broken-window.png)

(Side note on how nice the FBI info site is regarding data [^fbi], although not all the historical data. Main graph
source: [^crime_rates])

[^crime_rates]: Statistic self-made, base chart and numbers
from [Chicago's homicide problem dwarfs those in New York, Los Angeles](https://wirepoints.org/chicagos-homicide-problem-dwarfs-those-in-new-york-los-angeles-wirepoints/)

[^fbi]: CSV Files for crimes by state by
the [FBI](https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/explorer/crime/crime-trend)

Broken Windows Policing became a revolutionary way of seemingly stopping crime early. With the following Mayor Michael
Bloomberg the police started the "Stop and Frisk" policy. It allowed the police to stop, question and collect
information on people without any concrete crime happening upfront, and with the vast majority stopped without any
conviction. Quickly the claims of racial profiling and criminalisation of poor people got louder [^frisk].

[^frisk]: [Stop and Frisk on Wikipedia](https://en.wikipedia.org/wiki/Stop-and-frisk_in_New_York_City)

What started with the idea of empowering neighbourhoods escalated to a lawsuit brought by the Center for Constitutional
Rights in 2013, ruling that stop-and-frisk had been used in an unconstitutional manner, followed by more lawsuits.

### Data on Broken Window Theory

During its history many studies tried to replicate the successes associated with Broken Window Policing. In 2016 a big
meta-analysis gathered an overview of the results and drawbacks of the studies.

The main meta-analysis of the evidence emphasises the systemic errors by focusing on "perceived" disorder in a
neighborhood with often interchangeable or vague definitions of disorder; also the studies fail to measure alternative
mechanisms (poverty, collective efficacy, pre-existing disadvantage) besides the given explanation.
The main critique of Daniel O'Brien is that most of the studies observing broken windows phenomena do not account for
collective efficacy, a community's capacity of creating or engaging in shared norm enforcement. This concludes that
disorder and crime are both co-symptoms of low collective efficacy, rather than disorder being the cause of
anything [^window].

[^window]: Broken (windows) theory: A meta-analysis of the evidence for the pathways from neighborhood disorder to
resident health outcomes and behaviors by Daniel T. O'Brien, 2018

A side note on an alternative study that tried to research between 2017 and 2020 how abandoned houses affected health
and
violence in a community in Philadelphia. Over these years randomly selected parts of the city received monthly
maintenance either through full renovations, cleanings, or nothing (as a control group). The city could report a
significant
drop of gun violence in the respective areas [^phili]. Broken window theory can be used to argue for cleaning and
maintenance in public areas, but given the history of racial and poverty profiling I am not sure if one should try
to use it as an argument.

[^phili]: [Philadelphia Experiment on Broken Window Theory](https://penntoday.upenn.edu/news/Penn-Columbia-research-abandoned-house-repairs-reduced-nearby-gun-violence)

## Back to Software Engineering

Given the negative impact on society, and the possibly discriminating assumptions about poverty, this study is one that
should not be thoughtlessly quoted. Additionally, the Broken Window Theory is a topic of sociology or criminology -
not psychology. Its projection into software engineering is not straightforwardly possible in my point of view. Still,
it seems like a popular idea.

I found too many blog posts or podcasts on Broken Window Theory in software engineering, proposing the
idea that a high frequency of code smells or technical debt ("broken windows") would encourage developers to lower their
standards and also write lower quality code. Even otherwise nice and modern books I did read statements like _"Thus
[Broken Window Theory], a small bit of bad code should not be seen as an isolated problem. It should be seen as a broken
window, as a catalyst for systemic rot."_ [^humans].

Broken Window Theory does fit the narrative of our developer culture - framing clean code as so important that even
small divergence can be a slippery slope to the next legacy code nightmare.

[^humans]: Code Is for Humans: A Guide to Human-Centric Software Engineering by Zohar Jackson

### Studies on Broken Window Theory in Dev Teams

I found two studies that compared the code quality changes of codebases over time (one by monitoring open source repos,
one by following different groups of developers). They try to estimate the quality of code introduced into a
codebase by somewhat objective measurements and compare this over time in code bases with different levels of tech
debt. 
The studies do partially acknowledge the problematic background of the theory [^spinellis] [^levin].
And they both show that bad code in a codebase will more likely increase.

In my opinion both studies follow the history:
They do not define code quality in a cohesive way (which I must agree is not an objective task and very much depends
on the code, the team, and the goal of the project). They don't control against mimicry as an act to keep a
code base consistent to a certain degree, even if some copied patterns might be smelly in a better code base. Sometimes
it is just more confusing to change coding style and naming within a function.
Most importantly in my point of view they do not sufficiently account for the collective efficacy of the teams. Team
culture is hard to measure, and especially the study based on open source code might have bigger challenges to
identify how coding standards are discussed and established within an open source community, but the study that compared
two dev teams could have at least mentioned differences in their team culture.

Both studies mention their own limitations in a transparent way. Still, their goal of correlating new code smells to
existing ones under the framing of Broken Window Theory seems to me very unconvincing considering the historic
background. I would have found papers that focus on "Can team culture reduce code smells over time?", "if resources 
are spend just to improve small code smells, will the code base keep up the higher code standard?", both could be 
used with and without a broken window framing. 

A dev team's ability to define norms, embrace code review culture, and maintain shared standards as a plausible
common cause of both new and existing technical debt sounds like a plausible idea to me. A team
with low collective efficacy might produce more low quality code because the standards are not enforced nor
communicated within the team.

[^spinellis]: "Broken Windows: Exploring the Applicability of a Controversial Theory on Code Quality", by Diomidis
Spinellis, Panos Louridas, Maria Kechagia and more in 2024

[^levin]: "The Broken Windows Theory Applies to Technical Debt", by William Leven, Hampus Broman, Terese Besker, and
Richard Torkar in 2022

### Alternative points of view

What would the consequences of such studies or statements be for devs? Should a "Code Order Manager" ensure even
small code smells are taken care of, thereby keeping the code base clean? Or should we rather take that learning
from history and directly jump to the question of how community efficiency can be measured and encouraged?

As an honorable mention: code with "broken windows", with code smells like long functions, badly named variables,
duplicated code, or unstructured design is plain hard to work with. It is frustrating, it takes longer to solve even
easy problems in such code, and it is much harder as a developer to feel proud of the code. Criticizing every bit of
smelly code sounds additionally demotivating if there is no team vision for the quality and design of the future code,
feeding some intrinsic motivation to only commit good code in a smelly code base.

There are multiple studies and even a systematic review [^social_debt] that looked at the correlation of problematic
team culture and technical debt. It identifies _Social Smells_ inspired by code smells that serve as sociotechnical
antipatterns, leading towards rising _Social Debt_, the unexpected accumulated cost from suboptimal software
development processes. Across all 25 studies the second most often referred effect of many social smells is higher
technical debt (the most often was lowered cooperation).

[^social_debt]: "Community Smells - The Sources of Social Debt: A Systematic Literature Review" by Eduardo
Caballero-Espinosa, Jeffrey Carver, Kimberly Stowers (2022)

## Conclusion

The Broken Window Theory keeps showing up in dev circles because it tells us what we want to hear — that quality
matters (it does), and that small things compound (they do). But the theory carries a lot of historical baggage, and
most people invoking it for clean code haven't done the reading. If the goal is a healthy codebase, I'd rather talk
about team culture, psychological safety, and shared ownership than reach for a metaphor with a complicated past.
