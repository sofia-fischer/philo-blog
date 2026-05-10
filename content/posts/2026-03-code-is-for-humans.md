---
title: "📚 Code is for Humans"

date: 2026-05-10T10:20:44+02:00

draft: false

description: "A book take away for \"Code is for Humans\"."

tags: [ "Code Quality", "Software Patterns", "Books" ]

---

## Code is for Humans

The following paragraphs are my learnings of the Book "Code is for Humans" [^book]. It consists of quotes of the 
book forming somewhat a summary of the most important parts, followed by my comments and thoughts.

[^book]: [Code is for Humans: A Guide to Human-Centric Software Engineering by Zohar Jackson](https://codeisforhumans.com)

### Defining Good Code

> [Software Engineers] must optimize over a variety of parameters such as system stability, short-term development
> costs, long-term development costs, upcoming deadlines, cost-of-compute, user satisfaction, user safety, office
> politics, etc. ... Define your goals and constraints, then figure out what the best code is given those goals and
> constraints. Focus on the objective and the definition of "good" [Code] will follow.

Good code is not necessarily the most resource efficient algorithm, but the code that fits best to the goal of the
project. Not every piece of code is made to last forever, but only to prove a concept, to visualise an idea, or to
establish the first iteration of a product. Sometimes short-term costs don't matter, sometimes long-term costs are not
the priority.

> Software engineering is not computer science.

Software engineering deals with uncertainty, human habits, and stakeholder desires. But why would that mean that it is
not researched, based, and practiced in Computer Science? Not every part of Computer Science includes software
engineering, and not all software projects will equally borrow accomplishments from all Computer Science - but viewing
software development as one discipline researched by computer science enables us to test software development ideas
scientifically.

> Tradeoff analysis, as the name implies, is the process of analyzing the various tradeoffs of a decision. In terms of
> engineering, it consists of determining and considering the advantages and disadvantages of each engineering choice,
> including how each choice affects the product and team, both locally and holistically.

Throughout the book Zohar Jackson emphasizes that different solutions come with tradeoffs, and that sometimes a
probabilistic model can be a great tool to turn uncertainty into a game theoretical calculation. The cost of bad code
now, plus the cost of understanding bad code in the future, plus finally replacing bad code with good code - compared to
writing good code in the first place is a nice visualization of how code that is not written for the human to understand
causes actual cost. On the other hand, one can spend infinite resources on writing perfect code; at some point there
will be a point reached, after which adding resources to refining the code will not result in reduced development cost
in the future (the law of diminishing returns).

#### Code is meant to be read by humans

> Code is a tool for human minds. Code is meant to be written, read, modified, and understood by humans, not machines.

{{< alert "comment" >}}

This idea is the main reason I bought the book. I love and practice the idea that one of the most important users of the
system is the developer who will work with the code in the future - and that the code should be written keeping their
requirements in mind.

This means a developer could read the code who misses the domain knowledge, or doesn't know the software pattern you are
using, or it could be your future self, who happened to forget that the additional, counter-intuitive check was added
because it fixed a small bug last year.

Next to the future developer I would mention, that there are more users to the system.

* The Infrastructure / Devops Engineer who will deploy the code and would appreciate if it does not cause system jobs
  running over days or never closing database transactions that cause them extra work.
* The Data Analyst who will try to extract useful information from the data you stored, and who doesn't know that you
  thought keeping the old database column name would not cause harm because you did write a comment in code explaining
  why the column name no longer matches the content.
* The Security / Data Privacy Representative who will need to find a reasonable explanation for why the endpoint with
  customer data did not have authentication, because you thought it was obfuscated enough to count as secure.
* The personification of "Earth" who will provide the resources to run your code, even if you thought the n+1 problem
  would be worth it to keep this file within the expected "lines of code" limit you find aesthetic.
  {{< /alert >}}

Computers don't care about readability as long as they can compile it; the machines will understand.
For human minds on the other hand, it matters how information is presented. Code that requires many items of information
in memory is hardly a problem for a computer, while it makes engineers struggle.
A variable name might not change the association of a computer, but for the developer it can cause friction when reading
through a function. Also, even minor mis-specifications will cause a computer to error, while a human might still have
succeeded.

Code is written for humans. Tests are nothing a computer needs, but something that helps to catch human errors.
Comments aren't for the compiler, but for the developer. The computing power and memory of an engineer costs much more
than that of a computer.

> How [does the code] make you feel?

A really nice question, that I agree is underestimated. The feeling of being overwhelmed and already frustrated when
looking at complex code that, even if it needs to be complex, does not need to look overwhelming.

> Much of the difficulty in writing quality code comes from the difficulty of translating the complexities of the
> universe into the language of our minds.

This emphasizes that the main challenge for a software engineer is not making the machine understand what it should do,
but to successfully design abstractions that simplify the universe into comprehensible models that will be understood by
humans.

### Abstractions

**Abstractions**

> Reality is far too detailed and complex. We need abstractions to simplify the complexity of reality into small chunks
> that can fit in our memory and be usable for processing.

When designing a data structure, its properties will never consist of all its real attributes, but only a (for some
user) relevant subset. Storing properties that do not matter, that do not help the program nor are interesting to the
user introduces unnecessary (and costly) complexity.

Abstractions also help software engineers to hide code whose understanding is not required for the current process. The
hardware limitations, operating software constraints, or database caching are hidden away, so one can focus on writing
business code without the requirement of understanding every layer used in computation.
In the same way, extracting a complex but not necessarily relevant part of a function into its own function hides away
complexity until a user is ready and curious for more detailed knowledge.
This progressive disclosure of complexity can also be a great tool in designing UX or documentation.

**Models**

> A model is a particular type of abstraction that is used to understand, analyze, predict, and explain the behavior of
> a system.

Models help humans to understand processes by simplifying or adding assumptions. A famous example Zohar Jackson also
uses are the Newtonian vs. Einsteinian equations for calculating force - the famous model of
`Force = Mass * Acceleration` is sufficient for most cases in which the complexity of relativity does not matter.
Software Engineers also use such models and simplifications - for example most developers would not calculate `π (Pi)`,
but use a constant as a simple approximation.

Similar to the chapter about defining "good" code, defining a "good" model depends on your goals. Every model in the end
is wrong and a simplification of reality. There will always be constraints or assumptions that make the same model
useful in one case and cause dangerously false results in another.

### Zohar Jackson's idea of Natural Language Complexity

Following the line of thought that abstraction reduces complexity, Zohar Jackson introduces a measurement of complexity:

> A rough way of measuring the cognitive load of an abstraction is to consider how many natural language words are
> needed to fully describe the abstraction. We can call this measure of complexity natural language complexity (NLC)
> [...]. This measurement of complexity is inspired by Kolmogorov complexity, a measure of program complexity that 
> is defined as “the length of the shortest possible description of the string in some fixed universal description 
> language”

Kolmogorov complexity does not deal with cognitive complexity, but is a measure of the compressibility and computational
resources needed to specify an object. Kolmogorov complexity is not about the length of a natural language explanation
of something — it's about the minimal formal specification needed to reproduce a bit-string exactly.
Going from this computational complexity to cognitive complexity is, in my view, not well thought through.

The idea of using Kolmogorov Complexity to compare it to cognitive complexity itself is not invalid. There even is a
paper from 2013, "Bounded Kolmogorov Complexity Based on Cognitive Models", that tests the correlation between both by
using Kolmogorov Complexity to describe number sequence problems used in IQ tests (incidentally, a great example of how
Software Engineering as a research field within Computer Science enables such research). The results show that
Kolmogorov Complexity can be used for cognitive measurement for identifying patterns in __number sequences__, and that
these results are limited to only the human cognition of pattern finding in number sequences. The paper also introduces
a modelling system to map the human understanding of a string into a computational language to specifically avoid
judging the natural language description of the human. [^paper_kolmogorov]

[^paper_kolmogorov]: Bounded Kolmogorov Complexity Based on Cognitive Models by Claes Strannegård, Abdul Rahim Nizamani,
Anders Sjöberg, and Fredrik Engström in 2013

But applying this to the cognitive complexity of code is a very large leap, not only because describing an algorithm in
natural language is far more complex than describing a sequence of numbers. Also, why would word count be a valid
measurement of natural language complexity? If developers don't take lines of code as a reasonable measurement for 
complexiy, why should linguistics? I have discussed this in more depth in
my [post about code complexity with a small bit of linguistic complexity]({{< ref "posts/2026-04-code-complexity" >}}).

I can only emphasize that "word count in natural language = cognitive complexity" is too much of a simplification -
especially given existing, tested, and validated measurements of complexity compared to what Zohar Jackson has proposed
here.

### Cognitive Complexity

> Cognitive load theory provides a model of how human brains learn, process, and store information. The theory suggests
> that learning and thinking happen best when information is structured and presented in a way that is aligned with the
> human cognitive architecture. [...] Cognitive load is measured in terms of the amount of working memory used. The more
> working memory used, the higher the cognitive load.

As learned in the [Refactoring Book by Martin Fowler]({{< ref "posts/2026-02-refactoring" >}}), one of the main goals of
refactoring is to reduce the cognitive load on the reader. The book provides many tools on how to identify cognitive
load and how to tackle high cognitive load.

> Featuritis is a term used to describe a situation in which a product has too many features, making it overly complex,
> difficult to use, and hard to maintain.

> Over-engineering in software development refers to the practice of creating overly complex and unnecessary solutions
> to problems.

Complexity can also be applied to both the UI user and the developer user.

> Cognitive load theory breaks down cognitive load into three types: intrinsic cognitive load, extraneous cognitive
> load, and germane cognitive load.

Intrinsic cognitive load is the inherent difficulty of the domain itself. I have found that developers easily fall into
the fallacy that because any complicated domain process can be modelled as code, they can therefore understand any given
domain process. Modelling domains is a complex task, and is in my view the type of cognitive load that can hardly be
reduced.

Extraneous cognitive load refers to the way a topic is presented, which I interpret in both ways: how given domain
documentation explains the processes and how the existing code models the domain.

Germane cognitive load is the amount of mental effort required to process and learn new information. This sounds to me
like a focus on learning culture, the required feeling of safety to learn topics, and to regularly question one's
understanding of them.

### Assumptions and Familiarity

**Assumptions and Familiarity**

> The sort() function is an example of an abstraction which uses assumptions to reduce complexity. It is a reasonable
> assumption that the function will sort alphabetically from A–Z, as this is the default cultural standard for sorting.
> [...] As an engineer, it is absolutely critical that your users (the people reading your code) will make the same
> assumptions as you.

Such assumptions — that the user will (often by experience) know how functions or systems will be used — can offer
implementation simplification as well as a seamless user experience.

> Humans are biased to think that what we know is known by others. This cognitive bias even has a name: the curse of
> expertise or the curse of knowledge. You must work hard to unbias your assumptions about other people’s knowledge.

On the other hand, it is easy to make false assumptions, to miss cultural differences, or to overestimate the experience
of users. After watching users in my grandparents' generation use technology, any assumption that is only shared within
a subset of the user group adds barriers for the other users.

Even worse is deceptive familiarity, which seems familiar to the user but is consciously or unconsciously implemented to
behave differently than expected. If done consciously this is a dark pattern, and I am sure everyone who clicked on the
highlighted option on a cookie-consent-popup will know the feeling of being tricked by such design.

> Producer’s bias is a cognitive bias which refers to the phenomenon of individuals underestimating the complexity of
> products they themselves have produced.

> The curse of cognition occurs when a person underestimates the cognitive differences between individuals; when they
> assume others have similar mental processes, cognitive strengths, and weaknesses as themselves.

> Possibility bias [...] is the tendency to overestimate the number and likelihood of positive or neutral possible
> outcomes and underestimate the number and likelihood of negative outcomes.

Zohar Jackson rightfully emphasizes the importance of communication between the developer and the user, and lists
multiple biases that a developer should consider when trying to empathise with the user's experience of the system.
Different users will process the same presentation of information in different ways. Good user experience and good code
should strive to catch such misunderstandings, also accounting for the users that are not covered by "most users will
understand this".

> One approach to reducing the effects of these biases is to intentionally write code for everyone, designed for the
> lowest reasonable denominator (LRD) of cognitive abilities, skills, and knowledge.

### Code is a tool to achieve human goals

> If you just thought to yourself that the inconvenience [...] endured was due to a user error and not a design error,
> then you are mistaken. All user errors are design errors.

Small software design errors can lead to thousands of users struggling daily with inconvenience.
This can come in many forms:

* The expert domain user, whom the software system restrains from using the software in the most efficient way, e.g. by
  not implementing keyboard shortcuts, not linking information that is often used together, or hiding information in
  walls of text.
* The uninformed domain user, who needs to look up the handbook to use the software that could also have displayed a
  corresponding help text.
* The user who relies on third-party software to interact with the system - like translations, screen readers, or
  keyboard-only navigation.
* The developer who is using an API and made assumptions about its capabilities that do not match its actual
  capabilities, but was never warned about unexpected limitations or usage constraints.
* The developer who cannot understand the code despite their best effort and then makes a best guess about how the new
  feature might fit into the existing code.

> But blaming the problem on human error is not going to prevent it from happening again.

It is the developer's responsibility to respond to "human errors" with design improvements to prevent recurrence. Using
existing patterns (both UX patterns and software patterns) is the basis of designing understandable software systems.
Zohar Jackson multiple times refers to the Zen principles of Python [^python] as example guides to achieve systems like
this, and I very much agree that those can be applied to UI users as much as to developer users.
Asking "5 Whys" when investigating an error — and especially continuing after one of the why-questions was answered
with "the user made a mistake" — is a very reasonable practice to embrace.

[^python]: [The Zen of Python](https://peps.python.org/pep-0020/)

> The broken windows effect occurs in software just as much as it does in neglected neighborhoods. [...] If everyone
> is writing bad code, then it excuses any individual to do the same.[...] Thus, a small bit of bad code should not be
> seen as an isolated problem. It should be seen as a broken window, as a catalyst for systemic rot.

The broken windows theory is heavily disputed, if not outright disproven. The idea was that even small indicators of 
disorder in a community are a sign that the community is neglected, and therefore inviting more serious crime.
Historically, it caused over-policing of minority communities and criminalization of poverty after the NYC police
interpreted the idea as a reason to introduce "zero-tolerance" policing to charge even minor infractions ("broken
windows") as protection against more serious ones.

Regardless of the study used as a basis for the argument, I don't see how this statement fits with the rest of the book.
In the beginning Zohar Jackson made it clear that software projects are created with limited resources and different
goals, and now every piece of bad code is to be objected to? In earlier chapters, writing bad code (as user errors of
the developer) was interpreted as a result of bad system design or external constraints like deadlines — and now a
single line of (subjectively) bad code should be immediately called out?
I find it a bit too close to the NYC interpretation of "zero tolerance", and too far away from investigating the real
root cause of "the small bit of bad code".

Given the negative impact on society, and the potentially discriminating assumptions about poverty, this is a study that
should not be thoughtlessly quoted. Using — and thereby spreading — such a misleading, debunked (in 2018) study in a
book released in 2023 is, in my opinion, a missed opportunity for a 2023 publication. It could have worked as 
another vote for "bad code are caused systemically", or it could have worked as "Developers need resources to write 
good code and refactor past mistakes". 

More on my opinion on broken window theory in [this post]({{< ref "posts/2026-03-broken-window-theory" >}}).


> Bad design is forever

The stated concerns regarding the longevity of design errors is something I fail to understand.
While Zohar Jackson is bothered by the `/bin` vs `/usr/bin` split from the 1970s, I don't really see the cost of the
symlink that computers now keep between the directories to maintain backwards compatibility.

On the contrary, I find it remarkable how developers achieve new solutions within historic limitations.
HTTP/2 uses TCP to establish a connection — a great solution at development time that later became a limitation, no
longer fitting the requirements of loading multi-file web pages and the need for encryption.
Using a combination of UDP and QUIC enabled higher performance and a greater portion of the package being encrypted,
without touching the original protocols in routers or servers. [^quic]

[^quic]: [Blog post explaining how QUIC and UDP are used in Http/3](https://pulse.internetsociety.org/en/blog/2023/06/why-http-3-is-eating-the-world/)

Maybe because I neither used the two other examples (neither `tar` nor (for a different reason) urinals), I think old 
software can build on by clever solutions, and if finding such solutions becomes to resource-consuming, it can be 
re-written - probably it should be more often rewritten. 

## Is Code for AI?

Today, most code is written not only for humans, but also for AI. With coding agents spending considerable resources on
understanding how code was written — should we even keep writing code for humans? **Yes!**

The usage of readable, easy-to-understand code is equally, if not more, important than in the past. One of the main
reasons is that AI is trained on human code, and by this has inherited human surprise patterns. Unexpected (and
therefore confusing) code slows AI agents down just like it slows humans down [^ai_perplexity]. There might be pieces of
code that are particularly confusing for humans but not AI, or vice versa, though.

[^ai_perplexity]: [How do Humans and LLMs Process Confusing Code?](https://arxiv.org/pdf/2508.18547)

Not only constructs and patterns can slow down LLMs in understanding code, but also naming and references to the domain
are used to understand, validate, and contribute. In one experiment, code was obfuscated by removing all meaningful
variable or method names. With all references to the domain the code handled removed, the AI had a much harder time
understanding the code — just as humans benefit from context given by names, comments, and naming
patterns. [^ai_understanding]

[^ai_understanding]: [When Names Disappear: Revealing What LLMs Actually Understand About Code](https://arxiv.org/pdf/2510.03178)

## Conclusion

Code is for humans. The title of the book already phrases its intents and main message - with which I fully agree!
Writing the code for the developer who will use the code can not be often enough emphasized on.
Even in the current time of AI agents reading and writing the code next to humans, because of their inherently humans
thinking patterns the book only gains in importance.

I do critique some of the statements in the book (like the critique of Computer Science, the simplified measurement
of complexity, or the uninformed mentioning of broken window theory), where I found the book way too shallow.

Happy Coding :)