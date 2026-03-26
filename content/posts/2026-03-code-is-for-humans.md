---
title: "📚 Code is for Humans"

date: 2026-03-28T10:20:44+02:00

draft: true

description: "A book take away for \"Code is for Humans\"."

tags: [ "Development", "Software Pattern", "Book" ]

---

{{< lead >}}
A book take away for \"Code is for Humans\", with a couple of side tracks into linguistic and AI critique.
{{< /lead >}}

## Code is for Humans

The following paragraphs are my learnings of the Book "Code is for Humans" [^book]

[^book]: [Code is for Humans: A Guide to Human-Centric Software Engineering by Zohar Jackson](https://codeisforhumans.com)

### Defining Good Code

> [Software Engineers] must optimize over a variety of parameters such as system stability, short-term development
> costs, long-term development costs, upcoming deadlines, cost-of-compute, user satisfaction, user safety, office
> politics, etc. ... Define your goals and constraints, then figure out what the best code is given those goals and
> constraints. Focus on the objective and the definition of “good” [Code] will follow.

Good code is not necessary the most resource efficient algorithm, but the code that fits best to the goal of the
project. Not every code is made to stand forever, but only to proof a concept, to visualise an idea, or to establish the
first iteration of a product, sometimes short term cost don't matter, sometimes long term costs are not the priority.

> Software engineering is not computer science.

Software engineering deals with uncertainty, human habits, and stakeholder desires. But why would that mean that it is
not researched, based, and practiced in Computer Science? Not every part of Computer Science includes software
engineering, and not all software project will equally borrow accomplishments from all Computer Science - but viewing
software development as one discipline researched by computer science enables us to test software development ideas
scientifically.

> Tradeoff analysis, as the name implies, is the process of analyzing the various tradeoffs of a decision. In terms of
> engineering, it consists of determining and considering the advantages and disadvantages of each engineering choice,
> including how each choice affects the product and team, both locally and holistically.

Throughout the book Zohar Jackson emphasizes that different solutions come with tradeoffs, and that sometimes a
probabilistic model can be a great tool to turn uncertainty into a game theoretical calculation. The cust of bad code
now, plus the cost of understanding bad code in the future, plus finally replacing bad code with good code - compared to
writing good code in the first place is a nice visualization of how code that is not written for the human to understand
causes actual cost. On the other hand, one can spend infinite resources on writing perfect code, at some point there
just will be a point reached, after which adding resources to refining the code will not result in reduced development
cost in the future (The law of diminishing returns).

#### Code is meant to be read by humans

> Code is a tool for human minds. Code is meant to be written, read, modified, and understood by humans, not machines.

{{< alert "comment" >}}

This idea is the main reason I bought the book. I love and practice the idea that one of the most important users of the
system is the developer who will work with the code in the future - and that the code should be written keeping their
requirements in mind.

This means a developer could read the code who misses the domain knowledge, or doesn't know the software pattern you are
using, or it could be your future self, who happened to forget that the additional, contra intuitive check was added
because it fixed a small bug last year.

Next to the future developer I would mention, that there are more users to the system.

* The Infrastructure / Devops Engineer who will deploy the code and would appreciate if it does not cause system jobs
  running over days or never closing database transaction that cause them to extra work.
* The Data Analyst who will try to extract useful information from the data you stored, and who doesn't know that you
  thought keeping the old database column name would not cause harm because you did write a comment in code why the
  column name doesn't match the content anymore.
* The Security / Data Privacy Representative who will find a reasonable explanation why the endpoint with customer data
  did not have authentication, because you thought it was obfuscated enough to count as secure.
* The personification of "Earth" who will provide the resources to run your code, even if you thought the n+1 problem
  would be worth it to keep this file within expected "lines of code" limit you find aesthetic.

{{< /alert >}}

Computers don't care about readability as long as they can compile it, the machines will understand.
For Human minds on the other hand, it matters how information is presented. Code that requires many items of information
in memory are hardly a problem for computer, while it makes engineers struggle.
A variable name might not change the association of a computer, but for the developer it can cause fraction when reading
through a function. Also, even minor miss-specifications of a computer will cause an error, while a human might have
still succeeded.

Code is written for humans. Tests are nothing a computer needs, but something that helps to catch human errors.
Comments aren't for the compiler, but for the developer. Computing power and memory of an engineer costs much more than
of a computer.

> How [does the code] make you feel?

A really nice question, that I agree is underestimated. The feeling of overwhelmed and already frustrated when looking
at complex code that even if it needs to be complex does not need to look overwhelming.

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

Abstraction also help software engineers to hide code which understanding is not required for the current process. The
hardware limitations, operating software constraints, or database caching are hidden away, so one can focus on writing
business code without the requirement of understanding every layer used in computation.
In the same way, extracting a complex, but not necessarily relevant to understand part of a function into its own
function, hides away complexity until a user is ready and curious for more detailed knowledge.
This Progressive disclosure of complexity can also a great tool in designing UX or Documentations.

**Models**

> A model is a particular type of abstraction that is used to understand, analyze, predict, and explain the behavior of
> a system.

Models help humans to understand processes by simplifying or adding assumptions. A famous example Zohar Jackson also
uses are the Newtonian vs. Einsteinian equations for calculating force - the famous model of
`Force = Mass * Acceleration` is sufficient for most cases in which the complexity of relativity does not matter.
Software Engineers also use such models and simplifications - for example would most developers not calculate `π (Pi)`,
but use a constant as simple approximation.

Similar to the chapter about defining "good" code, defining a "good" model depends on your goals. Every model in the end
is wrong and a simplification of reality. There will always be constraints or assumptions that make the same model
useful in with one case and will cause dangerously false results in another.

### Zohar Jackson's idea of Natural Language Complexity

Following the thought of line that abstraction is reducing complexity, Zohar Jackson introduces a measurement of
complexity:

> A rough way of measuring the cognitive load of an abstraction is to consider how many natural language words are
> needed to fully describe the abstraction. We can call this measure of complexity natural language complexity (NLC),
> and we will refer to it throughout the book. This measurement of complexity is inspired by Kolmogorov complexity, a
> measure of program complexity that is defined as “the length of the shortest possible description of the string in
> some fixed universal description language”

Kolmogorov complexity does not deal with cognitive complexity, but a measure of the compressibility and computational
resources needed to specify an object. Kolmogorov complexity is not about the length of a natural language explanation
of something — it's about the minimal formal specification needed to reproduce a bit-string exactly.
Going from this computational complexity to cognitive complexity is in my point of view not a thought through.

The idea of using Kolmogorov Complexity to compare it to cognitive complexity itself is not invalid. There even is a
paper from 2013 "Bounded Kolmogorov Complexity Based on Cognitive Models" that tests the correlation between both by
using Kolmogorov Complexity to describe number sequence problems used in IQ tests (Btw, what a great idea! Just as side
note that Software Engineering as a research field Computer Science does enable such research). The results are that
Kolmogorov Complexity can be used for cognitive measurement for identifying patterns in __number sequences__, and that
these results are limited to only the human cognition of pattern finding in number sequences.The paper also introduces a
modelling system to map the human understanding of a string into a computational language to specifically avoid judging
the natural language description of the human. [^paper_kolmogorov]

[^paper_kolmogorov]: Bounded Kolmogorov Complexity Based on Cognitive Models by Claes Strannegård, Abdul Rahim Nizamani,
Anders Sjöberg, and Fredrik Engström in 2013

But applying this to the cognitive complexity of code is a very far jump, not only because describing an algorithm in
natural language is far complexer than describing a sequence of numbers.

This conflates Map with the territory - measuring the description of the abstraction does not necessarily reflect the
cognitive load of the code for the developer working with it. A famous example of something that developers might be
able to explain easily, but still cannot easily comprehend in code is the concept of a Monad in Haskell.

For which audience is the algorithm described? In what detail are business decisions described? Is by this measurement
the description of an algorithm for the formular`E = mc^2` as simple as "Energy equals mass times the speed of light
squared" or does this require a more complex natural language description? What amount of domain knowledge is expected
by the reading developer? If extreme knowledge about a topic can be assumed, even "low quality" code can have a low
perceived complexity - I once had the chance to read through the code of a geophysics academic, and the one-letter
variables and complex, undescribed functions where sufficient assuming the code reader where aware of the required
physics knowledge.

Why would be word count a valid measurement of natural language complexity? Just looking superficial look into
linguistic complexity compared to programming complexity revealed the shared properties. Historically, both seem to have
influenced each other, with natural language inspiring formal languages and formal grammar as basis for compilers and
vice versa programming complexities like Cyclomatic complexity inspiring parse trees in linguistic, and many more
interdependencies. Examples of Linguistic Complexity measurements that compare to algorithmic complexities are:

* Subordination index, Count of subordinate clauses which each add a new "branch" to parse <-> Cyclomatic complexity
  Independent paths through code, each if/while/for adds 1
* Mean dependency distance (MDD) Average word-gap between a head word and its dependent (like an adjective depends on
  the noun it modifies) <-> Variable scope distance Lines between a variable's declaration and its use
* Incomplete dependencies (DLT) Count of open syntactic promises at any parse point <-> Parser stack depth, Unresolved
  open brackets / function calls on the stack
* Type-token ratio / entropy, Unique words ÷ total words to measures vocabulary diversity <-> Halstead vocabulary /
  entropy Unique operators+operands ÷ total operands

Looking at therese should emphasize that the simplification "word count in natural language = cognitive complexity" is
too much of a simplification - especially with existing, tested and validated measurements on complexity that are
compared to what Zohar Jackson's just proposed here.

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

Complexity can also be applied to both the UI user and the dev user.

> Cognitive load theory breaks down cognitive load into three types: intrinsic cognitive load, extraneous cognitive
> load, and germane cognitive load.

Intrinsic cognitive load is the inherent difficulty of the domain itself. I made the experience, that developers easily
follow the fallacy, that because any complicated domain process can be modelled as code, that they can understand any
given domain process. Modelling domains is a complex task, and is in my point of view the cognitive load that can hardly
be reduced.

Extraneous cognitive load refers to the way a topic is presented, which I interpret in both ways how given domain
documentation explains the processes and how the existent code models the domain.

Germane cognitive load is the amount of mental effort required to process and learn new information. This sounds to me
like a focus on learning culture, the required feeling of safety to learn topics and to regularly question once
understanding of the topic.

### Assumptions and Familiarity

**Assumptions and Familiarity**

> The sort() function is an example of an abstraction which uses assumptions to reduce complexity. It is a reasonable
> assumption that the function will sort alphabetically from A–Z, as this is the default cultural standard for sorting.
> [...] As an engineer, it is absolutely critical that your users (the people reading your code) will make the same
> assumptions as you.

Such assumptions, that the user will (often by experience) know how functions or systems will be used can offer
implementation simplification as well as a seamless user experience.

> Humans are biased to think that what we know is known by others. This cognitive bias even has a name: the curse of
> expertise or the curse of knowledge. You must work hard to unbias your assumptions about other people’s knowledge.

On the other hand, it is easy to make false assumptions, to miss cultural differences, or overestimate the experience of
users. After watching users in my grandparents generations using technologies, any assumption that is only shared in a
subset of the user group is adding barriers for the other users.

Even worse is deceptive familiarity, which seems familiar to the user but is consciously or unconsciously implemented to
behave differently than expected. If done consciously this is a dark pattern, and I am sure everyone who clicked on the
highlighted option on a cookie-consent-popup will know the feeling of being tricked by such design.

> Producer’s bias is a cognitive bias which refers to the phenomenon of individuals underestimating the complexity of
> products they themselves have produced.

> The curse of cognition occurs when a person underestimates the cognitive differences between individuals; when they
> assume others have similar mental processes, cognitive strengths, and weaknesses as themselves.

> Possibility bias [...] is the tendency to overestimate the number and likelihood of positive or neutral possible
> outcomes and underestimate the number and likelihood of negative outcomes.

Zohar Jackson rightfully emphasizes the importance of the communication between the developer and the user, and lists
multiple biases that a developer should consider when trying to empathise the users experience with the system.
Different users will process the same presentation of information in different ways. A good User Experience and good
Code should strive to catch such misunderstandings, also considering for the users that are not covered by "Most users
will understand this".

> One approach to reducing the effects of these biases is to intentionally write code for everyone, designed for the
> lowest reasonable denominator (LRD) of cognitive abilities, skills, and knowledge.

### Code is a tool to achieve human goals

> If you just thought to yourself that the inconvenience [...] endured was due to a user error and not a design error,
> then you are mistaken. All user errors are design errors.

Small software design errors can lead to thousands of users struggling daily with inconvenience.
This can come in many forms

* The expert domain user, whom the software system restrain from using the software in the most efficient way, e.g. by
  not implementing keyboard shortcuts, not linking information that is often used together, or hiding information in
  walls of text.
* The uninformed domain user, that needs to look up the handbook to use the software that also could have displayed a
  corresponding help text.
* The user that relies on third party software to interact with the system - like translations, screen readers, or
  keyboard only navigation.
* The developer that is using an API, and made assumption of its capabilities that do not match its actual capabilities
  but never warned about unexpected limitations or usage constraints.
* The developer who cannot understand the code although trying by best effort and then makes a best guess how the new
  feature might fit in the existing code.

> But blaming the problem on human error is not going to prevent it from happening again.

It is in the developers responsibility to react to "human errors" with design improvements to prevent it. Using existing
patterns (both UX patterns and software patterns) are the basis of designing understandable software systems.
Zohar Jackson multiple times refers to the zen principles of python [^python] as example guides to achieve systems like
this, and I very much agree that those can also be applied to UI users as they can for dev users.
Also asking "5 Why's" when investigating an error, and especially continuing after one of the Why-questions was answered
with "The user made a mistake" is a very reasonable thing to embrace.

[^python]: [The Zen of Python](https://peps.python.org/pep-0020/)

> The broken windows effect occurs in software just as much as it does in neglected neighborhoods. [...] If everyone
> is writing bad code, then it excuses any individual to do the same.[...] Thus, a small bit of bad code should not be
> seen as an isolated problem. It should be seen as a broken window, as a catalyst for systemic rot.

The broken windows theory is heavily disputed if not outright disproven, as I discussed
in [this post]({{< ref "posts/2026-03-broken-window-theory" >}}). The idea was that even small indicators of
disorder in a community are a sign that the community is neglected, and therefore inviting more serious crime.
Historically It caused over-policing of minority communities and criminalization of poverty after the NYC police
interpreted the idea as a reason to introduce a "zero-tolerance"policing to charge even small delicts ("broken
windows") to protect against more serious delicts.

Given the negative impact on society, and the possibly discriminating assumptions about poverty make this study one that
should not be thoughtlessly quoted.Using and by this spreading such misleading, debunked (in 2018) studies in a book
released in 2023 is in my opinion quite a blunder.

Regardless of the study used as basis for the argument, I don't get how this statement fits in the rest of the book. In
the beginning of the book Zohar Jackson made it clear that software projects are created with limited resources and
different goals, and now every piece of bad code is to be objected? In the past chapters writing bad code (as user
errors of the developer) where interpreted as a result of bad system design or external constraints like deadlines, and
now a single line of (subjectively) bad code should be blamed immediately to uphold social standards in the team?
I find it a bit too close to the NYP interpretation of "zero tolerance", and too far away from investigating the real
root cause of "the small bit of bad code".

> Bad design is forever

The stated concerns regarding the longevity of design errors is something I fail to understand.
While Zohar Jackson is bugged by The `/bin` vs `/usr/bin` split from the 1970's, I don't really see the cost of the
symlink that computers now keep between the directories to be backwards compatible. Also for the other examples I could
not really agree, maybe because I neither use `tar` nor do I (for a different reason) use urinals.

On the contrary I find it amazing how developers achieve to implement new solutions within historic limitations.
Historically Http/2 uses TCP to establish a connection, what was a great solution at development time was now a
limitations that did not fit current requirements of loading of multi-file web pages and need for encryption.
Using a combination of UDP and QUIC enabled higher performance and a greater portion of the package encrypted without
touching the original protocols in routers or servers. [^quic]

[^quic] [Blog post explaining how QUIC and UDP are used in Http/3](https://pulse.internetsociety.org/en/blog/2023/06/why-http-3-is-eating-the-world/)

## Is Code for AI?

### Human-readable code is AI readable Code

### AI will not comprehend

## Conclusion

