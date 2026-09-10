---
title: "Human Error"

date: 2026-07-11T08:20:44+02:00

draft: false

description: "This book made me question the nature of human error not only in incidents, but all around me. The Field Guide to Understanding Human Error showed me the importance and benefits (and the intriguing side) of postmortem investigations."

tags: ["Communication", "Leadership", "Books"]
---

{{< lead >}}
This book made me question the nature of human error not only in incidents, but all around me. The Field Guide to Understanding Human Error showed me the importance and benefits (and the intriguing side) of postmortem investigations.
{{</lead >}}

## The Field Guide to Understanding Human Error

> A focus on ‘human error’ simplifies the enormously complex story of how people everywhere help create safety, how people have learned to cope, mostly successfully, with the pressures, contradictions and complexities of real work.

In this blog post I want to summarize my key takeaways on "The Field Guide to Understanding Human Error"[^human_error_book] and apply them from the book's examples of the medical field or power plants to the software developer domain. I'll add numerous quotes from the book like the above, and specify if I used a different source. The order of quotes or chapters does not match the book's.

[^human_error_book]: "The Field Guide to Understanding Human Error" by Sidney Dekker

---

_Within these italic blocks I provide a fictional incident. While I used my domain knowledge and experience to come up with a situation to apply the learnings of the book - this is a composite, dramatized scenario._

---

> The risk of having an accident is a fixed, structural property of the complexity of the systems we choose to build and operate.

## Old View / First Stories

---

_The company provides IT services for energy suppliers. The team in which the incident happened is working on parsing, processing, and responding to industry messages by which an energy supplier gathers information about their customers (like meter readings) or acts upon them (like handing them over from or to a different supplier). During the processing of a message it is decided if the request is legitimate (or contract binding forbids it, or the request is falsely made). Responding with an accept message or not responding within the regulated period leads to losing the customer._

_On a late Friday evening the developer merges their changes to the processing of one specific type of message. Before the change, the system incorrectly processed the message and defaulted to a fallback response causing false rejections, only minor human work for the operating team. One code reviewer comments that the change is bigger than scope of the bug, but probably overall a good change for the code, streamlining it to work like similar processes._

_After the change, the message processing works, but fails to send out the response. The developer does not look at the missing responses, but instead fixes am UI bug that was also included in the new code, and eventually stopps working until Monday. In the following days systems of multiple clients accumulate messages without response. A different developer points to the problem, with whose help a fixing merge is deployed and the messages are re-process by hand._

---

The incident is written from what the book calls the "Old View" on incidents. The overall problem is focused on the "who?" - the developer, the unreliable human behavior - as the cause of error. The developer did not apply propper care, the developer did not verify the whole process end to end, the developer prioritized the UI bug before going home instead of the real bug, the developer only started after they were pointed to the real bug...

### Results of the "Old View"

> Getting rid of Bad apples \[people who do not follow the rules and watch out carefully\] tends to send a signal to other people to be more careful with what they do, say, report or disclose. It does not make ‘human errors’ go away, but does tend to make the evidence of them go away.

This view on incidents implies that the human is the source of problems and guidelines and procedures need to be in place to control that. Checklists and protocols can increase safety if they are actually part of the daily work habits of people. There is no benefit in finding rule book quotes that state how the developer should have acted "by the rule book". They did not and adding more rules will not change that.

> Putting in more rules, procedures and compliance demands runs into the problem that there is always a gap between how work is imagined (in rules or procedures) and how work is done.

(Dekker is quoting Erik Hollnagel here)

Did the developer follow all the guidelines? No they did not - there was a little checkbox on the PR Template "This PR will deploy without error" and the developer did not even check it! Adding what is often phrased as "checkbox compliance" is not making a system safer. The developer followed the guideline to provide an end-to-end-test and multiple feature tests and followed all code style guides. But they did not check the box because it's meaningless in their day to day work.

> The shortcuts and adaptations people have introduced into their work often do not serve their own goals, but [...] those of your organization!

Software companies usually don't sell safety, but a well functioning service. The service in this case was not functioning well by business standards, and the developer prioritized fixing it. Not putting extra effort on safety was matching the priorities given to the developer for this ticket.

### Nobody comes to work with the intention to do a bad job

> People do not come to work to do a bad job. So when there are bad outcomes, you must look beyond those people, at the conditions in which they worked at the time.

The old point of view adopted by "First Stories" makes the assumption that the human could have been "more careful". However, even a 'better' developer might have introduced the same bug, as one study showed - Knowing who wrote or touched the code carries almost no predictive value of faulty code. What predicts defects with much greater accuracy are the meta informations like the file's size, churn, age, prior fault history, and how many hands were on it.[^defect detection]

[^defect detection]: "The limited impact of individual developer data on software defect prediction" by Robert Bell, Thomas Ostrand, Elaine Weyuker (2011)

> A worker’s proneness to have an accident turned out to be much more a function of the tools and tasks he or she was given, and the situations they were put into, then it was the result of any personal characteristics.

After the faulty code was merged, the situation would have presented itself the same for every developer, they would have access to the same monitoring and same tools to realize there was something wrong and how to fix it. A developer that knows how the situation unfolds, what the bug was, and how to resolve it of course could have changed everything - but the developer in this situation did not know that.

> The point of a ‘human error’ investigation is to understand why people’s assessments and actions made sense at the time, given their context, and without knowledge of outcome, not to point out what they should have done instead.

Understanding why the developer acted, why they made a bigger change than the initial task called for, why they focus on the wrong set of logs, why they fixed the UI bug but did not notice the underlying business bug - all those decisions the developer made made sense for them in that point in time, and it could have lead a different developer to the same conclusions.

> When something goes wrong, complexity is reduced to this simple, pernicious, term. ‘Human error’ has become a shape shifting persona that can morph into an explanation of almost any unwanted event.

In a nutshell, 'human error' is a simplification of the constellations that have led to an incident. We are working within a network of complex systems, 'human error' is a symptom of imperfections of those systems leading to incidents, not the reason for incidents. Every incident can be caused by a 'human error' if the people investigating did not ask enough questions and dig deep enough to find systemic error sources.

### Hindsight bias

> Hindsight means being able to look back, from the outside, on a sequence of events that led to an outcome you already know about. Hindsight gives you almost unlimited access to the true nature of the situation that surrounded people at the time ([...] what state the system was in versus what they thought it was in). Hindsight allows you to pinpoint what people missed and shouldn’t have missed; what they didn’t do but should have done.

Preventing the bug is easy if you know in which line the bug is in and what consequences it has. Knowing the edge cases that trigger the bug would have made it easy to design a test against it. Hindsight knowledge of the incident hides how small the chance of an incident seemed for the developers perspecive in time.

In hindsight the chain of events leading to the incident is linear, for the developer in media res it is a tree of possibilities (and followup possibilities) where the bug is coming from, how the system can be handled, and how the bug can be resolved.

> The hindsight bias [...] as a retrospective reviewer who knows the outcome of an event, you exaggerate your own ability to predict and prevent the outcome.

> The outcome bias [...] if the outcome (of an event) is bad, then you are not only more willing to judge the decisions, but also more likely to judge them more harshly.

Both of these biases make people tend to push responsibility and capability to predict and prevent the incident onto the operator (in my case the developers).

## New view / Second Story (of the same incident)

> This second story is inevitably an organizational story, a story about the system in which people work, about its management, technology, governance, administration and operation: Safety is never the only goal. Organizations exist to provide goods or services (and often to make money from it). People do their best to reconcile different goals simultaneously.

---

_On a Friday evening the developer merges their changes (same merge as describe above). The importance of the process step that the message represents implied it should be fixed quickly. The developer looked at the code and decided to not just fix the bug, but also reuse existing code to make any erroring processes fail safe and client manageable. These legacy implementations were known for bad error handling, silently failing, and there had been a team effort to improve that._

_All tests where passing, including one labeled as an end-to-end test, so the developer did not add a test. Hidden away in an obscurely named method this end-to-end tests mocked the actual sending of the message. The code was reviewed by another developer who also did not question the existing tests. After the change was merged the developer looked at the error monitoring for the client-manageable failed processes and did not find any failed ones, concluding processing of the message was working. During this, they also spotted a UI bug for which the developer delivered a fix quickly._

_The missing responses did not cause alarms because the error was only logged by a debug level log and neither existed a monitor specifically for missing responses. Many market partners disable their messaging services outside business hours - like on a Friday evening - because of which there was a low amount of inbound messages overall at this moment in time. The reduced absolute amount of failed messages was below the threshold of the monitor in place for errored messages and also too low for any operator to question._

_After the weekend the developer was pointed to the error by a coworker who had spotted the logs by sheer luck, and after a quick fix they could retroactivly reprocess all affected messages._

---

### Blameless investigation

> Don’t ask who is responsible, ask what is responsible. [...] People’s actions are systematically connected to features of their tools and tasks. Targeting those features (the what) is an action that contains all the potential for learning, change and improvement. Therefore, the first response to an incident or accident — by peers, managers and other stakeholders—should be to ask what is responsible, not who is responsible.

Many companies already know this by the term 'blameless'. Moving the focus away from the developer, focusing on the tools they had available and how they could have helped.

- The end-to-end test that mocked the last step of sending the response
- The exception that was lost in a debug log instead of an error log
- The missing monitor that checks for messages that need a response and alerts on missing responses
- The threshold for errored messages that hid a failure during a low-volume time

> What you believe should have happened does not explain other people’s behavior.

There is almost no benefit in discussing what a human should have done instead of what they did. Instead of "the developer should have looked at the logs!", the systemic critique would be "With an alert checking for missing responses the log would not have slipped through".

> Calling it a misdiagnosis is an unconstructive, retrospective judgment that misses the reasons behind the actual diagnosis.

Misattributing the root cause of a bug is a common occurrence in the moment, even when the actual cause may seem trivial to the hindsight observer. It’s easy for developers to stop looking, especially if misattributed root causes are valid bugs themselves. Improving monitoring with the knowledge of past blind spots is crucial to prevent misdiagnosis.

### The blunt end

> At the sharp end (for example [...] the cockpit), people are in direct contact with the safety-critical process. The blunt end is the organization or set of organizations that both supports and constrains activities at the sharp end (for example the airline [...]).

While the First Story looks at the sharp end, the Second Story looks at the blunt end. The blunt end gives the sharp end resources and expectations. Resources can include the monitoring tools that developers might need to know about an incident in the system, but it also includes training and knowledge about how these tools work and can be used, it also includes time to work with the tools given. Learning how to write structured logs, thinking about a strategy on what to monitor, or tweaking a monitor takes time that the blunt end needs to provide.

The blunt end has expectations on what should be delivered and what risks are worth taking - often a feature is higher valued than an improved test - which is partially in the nature of the blunt end because a feature can generate income.

## What about accountability?

> The job would not be fun, would not be meaningful, would not be worth it, if it weren’t for that responsibility and accountability. [...] This accountability forms the other side of professional autonomy and competence, to be seen to be good at what you do, and accepting the consequences when things do not go well. Such accountability gives people considerable pride, and it can make even routine operational work deeply meaningful. But people do want to be held accountable fairly. This means not only that they want to be held accountable by those who really know the messy details of what it takes to get the job done—not by those (managers, investigators, judges) who only think they know. It is also unfair to make people responsible for things over which they have no or little authority.

In my experience, developers enjoy their professional autonomy and competence a lot. Working in an environment that sees developers as often the only people who understand the system, who work with great autonomy, and have transparent pointers to "who caused what" can easily create a feeling of fear of the consequences, be it disciplinary consequences, learning the own code is not as resilient as expected, or consequences another human has to experience (in some rare cases a software bug is could cost a human life - an on-call engineer who sacrificed one night of sleep to get the system running might be more realistic). But it feels unfair being called out for code that changed without one's knowledge, for monitors that nobody felt responsible for, for an undocumented default, or for code that behaves unexpectedly differently than its naming or description or pattern indicated. Developers really want to write good code, and judge themselves often too much over mistakes their past selves did with best intentions, even if the mistake did not cause any harm.

If something (potentially) caused harm, and someone demands that the aftermath of that must also hurt, that demand is neither 'justice' nor 'accountability'. On the contrary, it is part of accountability to let people tell their story of what happened, and understand if the cause of the incident even was under their influence or authority to change.

> When you observe a consistent, repeated “Bad Apple” in your operation [...], you may be looking at a mismatch between the task and the person.

If there really is one developer that consistently causes incidents or introduces bugs, then I would question if the tasks given to the developer are well defined and understood, the coding standard is clear, and the support system around them is in place. An inexperienced developer will make mistakes, but it is the team culture that decides if they can learn from their mistakes in a pair programming session or in a production incident postmortem.

## How to investigate

Even before an investigation there should be a definition of what an incident is. Google's SRE book [^SRE_book] provides these categories I find useful:

- User-visible malfunction after a certain threshold
- Data loss of any kind
- On-call engineer intervention
- A resolution time above some threshold
- A monitoring failure

[^SRE_book]: "[Site Reliability Engineering](https://sre.google/sre-book/postmortem-culture/)" Chapter on Postmortems by John Lunney and Sue Lueder

The main thing I want to point out about these is, that the user does not need to be impacted. If just monitoring fails, or the on-call reacts that is already a reason to investigate (if this is labeled as 'incident' or not). This is especially important for the on-call engineers, because every on-call action should be investigated to reduce the number of interventions to not make on-call an unbearable burden.

### Steps of an investigation

> Which cues were observed (what did he or she notice/see or did not notice what he or she had expected to notice?)? What knowledge was used to deal with the situation? (...) What expectations did participants have about how things were going to develop, and what options did they think they have to influence the course of events? How did other influences (operational or organizational) help determine how they interpreted the situation and how they would act?

**1. Let people tell their story**. This step collects what knowledge was used and what actions were performed, not what could have been seen or done. What logs or metrics did you look up? Did you use the handbook and was it useful?
Inconsistencies within those questions can be normal, people perceive the same situation differently and this alone can also explain behavior.

> Time is a powerful organizing principle, especially if you want to understand human activities in an event-driven domain. Event-driven means that the pace of activities is not (entirely) under control of the humans who operate the process.

**2. Build a timeline**. Identifying the chain of events, the information that was available about the system and how events and actions influenced it. As with any model, the time line can reveal meta information. Organizing the time line not just as list of steps, but as a time scaled graph can enable us to see the big time slots in which nothing happened or in which many things simultaneously happened. This includes all the tools, which logs were written (which were missing), which monitor alerted when and what did the UI display? How did the system behave in each step in contrast to a normal business day?

Also the time line forces us to decide a starting point. With the introduction of the first bug, or with the creation of the follow-up ticket or with merging the second bug? This decision impacts the scope of the investigation - was the high priority of the ticket part of the incident? Was the known silent failure of the message process that the team tackled incrementally already part of the incident?

> Imagine that you don’t know the outcome. Try to reconstruct which cues came when, which indications may have contradicted them. [...] Try to understand how their understanding of the situation was not static or complete, as yours is, but rather incomplete, unfolding and uncertain.

**3. Combine the information on the system and monitoring state at every point in time and what the people knew can then be combined.** Mind that looking at this in hindsight lets one easily cherry pick the correct cues. Imagine the monitoring giving mixed cues about its status and most logs indicating a working process but one unexpected one is indicating what incident is about to happen. In complex systems there can be suspicious logs all the time, not knowing the outcome can easily cause one outlier to be ignored or seen as daily business.

> You end up hiding all kinds of interesting things by pasting a large label over your factual data. You can only hope it will serve as a meaningful explanation of what went wrong and why.

**4. Make the conclusions in the analysis of an incident auditable**. Phrases like "they lost situational awareness", "they did not look at the correct logs", "they didn't acted in compliance to our procedures" are hiding real causes. Write down in the analysis what conclusions the people made from data they had at that point in time. "The developer went home after they fixed the only bug they knew of and the error monitoring was displaying. The second bug was only visible in logs at that point in time". This can include the non-permanent data: a screenshot of the monitoring during that time frame, the "missing" error, the hidden log.

> Cause is not something you find. Cause is something you construct. How you construct it, and from what evidence, depends on where you look, what you look for, who you talk to, what you have seen before and likely on who you work for.

**5. Construct the causes**. This is a question on where you stop - the missed log? The uncompleted end-to-end-test? Product pushing the developer to a quick fix? The organization's model of risk on how many failing responses were "normal"? The original bug that started the work of the developer? There is a difference between work imagined and work done, and finding the cause should not point at the difference, only at the cause of that difference.

In complex systems there is never one single root cause - Just like there are multiple reasons the system is working correctly when there is no incident. Modern software systems contain many interdependences, that withstand a large number of bugs and inconsistencies until a strain of events actually crosses a tipping point and creates an incident. 

> The thing that explains a particular instance of failure does not need to be the same thing that allows your managers to do something about its potential recurrence.

The best fixes change the system so that the dangerous action is harder or impossible to repeat, or so that the system detects and recovers on its own: avoid the failure (type checking, end-to-end-tests), make the roll-out safe, make the danger visible quickly (and make it loud if needed), or remove the foot-gun that caused the misunderstanding. Recommendations do not necessarily point at the cause of an incident. If 80% of all incidents happen after bug fixes the recommendation is different to 80% of all incidents are not being covered by any monitoring.

### Safety Definition

> Safety I: safety is the absence of negative events. a system is safe if there are no incidents or accidents. (...) This often translates into trying to reduce the variability and diversity of people’s behavior—to constrain them and get them to adhere to standards. Safety II: safety is the presence of positive capacities, capabilities and competencies that make things go right. This is resilience: the ability of a system to adjust its functioning before, during or after changes and disturbances, so that it can sustain required operations under both expected and unexpected conditions.
> [^hollnagel_safety]

[^hollnagel_safety]: These are comments from Dekker on Safety-I / Safety-II distinction by Erik Hollnagel. See ["From Safety-I to Safety-II: A White Paper"](https://www.england.nhs.uk/signuptosafety/wp-content/uploads/sites/16/2015/10/safety-1-safety-2-whte-papr.pdf) (Hollnagel, Wears & Braithwaite, 2015)

The difference between Safety I and II is to focus away from things that go wrong to things that go right despite uncertainty, malfunction, complexity to understand how operators and engineers work to avoid incidents every day and how to support them.
In systems that already have a high standard of safety (which I would consider many developer teams that have type checking, tests, ci pipelines ...) the system can gain more safety by resilience. Enabling developers and even users to handle the unexpected error case requires a mindset in which the human is not a threat to the system, but a source of flexibility and resilience.

> building trust, with a comfort about being vulnerable and honest with each other when it comes to weaknesses or mistakes;

[Psychological Safety]({{< ref "posts/2026-06-psychological-safety" >}}) is a big part of this. This includes talking about incidents, and seeing them not as an individual happening but as team responsibility. Having Postmortems regularly, even on small incidents and "almost incidents". Those can build a habit of dealing with incidents in a safe way and make the system more resilient in the future. The worst thing that can happen after an incident is that people hesitate to report it or talk about what happened.

> Safety has increasingly morphed from operational value into bureaucratic accountability. Those concerned with safety are more and more removed— organizationally, culturally, psychologically—from those who do safety-critical work at the sharp end.

Checkbox safety as the result of some compliance or certification guideline is not safety and neither is writing one document to never be looked at again. Incident retros should happen at the sharp end where the developer is, not on a management level talking about developers. Developers should make incident postmortems a habit, talking openly about what they missed, how the system could be more transparent and more resilient.

## Conclusion

This post does not cover all the learnings in the book! I learned so much about safety culture, about how to investigate, how to model an incident, how to read through messages to extract meta information ... This book has been an adventure to read and I can only recommend it, it will change how you see incidents. The important learning "There is no human error" changed how I see my own incidents, how I judge "user error" if the UX I build is wrongly used, and what culture I push for in my team.
