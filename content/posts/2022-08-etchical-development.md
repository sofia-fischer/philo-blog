---
title: "Ethical Development"

date: 2022-08-31T14:20:44+02:00

draft: false

description: "Ethical behaviour helps a social group to flourish and strives to develop the best possible version
possible. Formulating it this way maybe describes why even the most rational minds in development should hold a second
to think about the code they are designing, implementing, or requesting. From an ethical point of view: Is your code
good?"

tags: ["Development", "Ethical", "IEEE 7000"]
---

{{< lead >}}
Ethical behaviour helps a social group to flourish, and strives to develop the best possible version.
Formulating it this way maybe describes why even the most rational minds in development should hold a second
to think about the code they are designing, implementing, or requesting.
This post is focused on one question: From an ethical point of view - Is your code good?
{{< /lead >}}

## Why ethical values matter in Development?

The trend towards ethical development is present in many ways. Social Networks may implement algorithms to reinforce
hateful but wide spreading content; smart home gadgets may contain sensors and microphones and therefore provide
more features and more engagement for exploiting; Governmental software is developed around the small border between
functionality and respect for their user privacy. Not in every company or context does society benefit from caring about
ethical issues; bitching about the cookie policy of a start-up might not make the world a better place;
but many developers, product owners, managers do not realise the ethical impacts of their decisions.

### Where to learn: IEEE

{{< alert >}}
Many clever people are thinking about the topic, my first touching point was IEEE, and it nudged me to wander down in
the
IEEE forest of interesting thoughts of engaged people all around the topic of ethics in technology. The fact that I did
that, does not mean it's the only source of truth, neither that it is best, nor that you should do the same - It was/is
my path, and I want to share my experience with that, and maybe inspire you to click on one of the links at stroll
yourself through the forest of information about ethics in IT.
{{< /alert >}}

![Corgi thinking about ethical questions?](/images/2022-08-thinker.png)

## Contemplating ethical stumbling stones

> IEEE’s CertifAIEd program objective is to enable, enhance and reinforce trust through AI Ethics specifications,
> training, criteria, and certification. It stems from the rationale that an entity benefits from an independent
> ethical evaluation and certification of its AIS. [^ieee]

[^ieee]: Check our [the CertifAIEd programm by IEEE](https://engagestandards.ieee.org/ieeecertifaied.html)

Although I have worked with AI, in my day-to-day business it's a tool I use, not the focus of my development business.
Anyway, the information IEEE offered was enlightening beyond the topic of machine learning. Being more aware
of the different areas in which I as a developer can encounter ethical issues while designing, implementing, or
maintaining a feature is a great help in avoiding ethical issues even before the first function call is written.

The following sections are the information I remember from the training. "Remember" like a not-complete list of hints,
metaphors, information, etc, that I found interesting enough to keep in mind. The CertifAIEd Program has (at time of
this post) 4 areas on interest: Transparency, Accountability, Algorithmic Bias, and Ethical Privacy.

### Transparency

Metaphor: In case of questions about a past flight (e.g. in case of a successful emergency landing, or a crash) there
are two black boxes on an airplane. The first one, the flight data recorder (FDR) records multiple technical parameters
about the state of the airplane and its surrounding. The second, the cockpit voice recorder (CVR) records the
conversation of the pilots in the cockpit. This metaphor can guide the two aspects of transparency.

The first is technical transparency. What data is recorded, how does it flow through the systems, and which decisions
are made by inside code? Especially in the context of anything that is labeled AI - to what degree does the developer
understand their algorithm? Is it clear to the developer how the system will be used by the end user? Who are the users,
is authentication tracked, activities logged, and errors handled? Mentioning the user, does the end user know how the
system works, are they aware of any automated systems that make decisions in the background, do they understand or at
least suspect how the algorithm decided on the displayed content, do they realise how the data is evaluated, stored, or
sold?

Secondly, the cockpit voice recorder: How did management make their decisions? Which business assumptions were made,
and how have they been communicated to development or sales? Does the company have an ethical set of values, and do
structures exist to enforce these? Those questions are not always easy, sometimes impossible to publish. But if possible
a company may benefit from providing information about their values.

### Accountability

Rubber stamps were used since the 18th century to mark documents as "seen and approved" by a given person following
some bureaucratic process. From that origin, the metaphor of rubber-stamping describes the tendency to uncritically
approve a given statement.

This tendency is one red flag when looking for accountability in a company. Enough bureaucracy can bury any liability -
some person approved this, some person for sure took responsibility for this; or vice versa the tendency to approve
something uncritically as part of the process without questioning them to be approved.

Being accountable does not end with a signature below a document to mark it as seen. An accountable person should be
able to display enough understanding of the subsystem in question to answer questions reliably. There is no black box
argument excuse to this - even if the subsystem in question is a black box for the accountable, answerability is not
optional. Additionally, this is not restricted to technical subsystems, but includes decisions and policies.

My two cents as a developer on this: As a developer, I often find myself in the position in which a manager might be
accountable for the feature I am asked to implement, while at the same time I might be capable of foreseeing ethical
issues he can't in context of the requested way of implementation.
This includes unethical features, like tracking sensible data, as well as unethical ways of implementation, like keeping
deleted user data in the backup files. I find myself responsible for at least questioning such requests, double-checking
if the ethical problems have been accounted for, and sometimes refusing to fulfil the request.
Not only, but especially as a developer, my decisions can have an impact on feature development, my workforce is one of
the most powerful resources I have to influence the future. Ethical value standards should come top to bottom, but I
encourage everybody to not underestimate the power of a single person questioning management requests.

### Algorithmic Bias

Computers are rational and free of human bias. That's what a lot of people, developers often up front, assume. People
tend to forget that every line of code is written by a human, prone to human bias. The view of computers as rational,
correctly calculating machines is especially dangerous if their algorithms contain repeatable errors, making decisions
about human beings resulting in unfair outcomes for one subgroup of users - all covered in the disguise of rational
calculations [^algoWatch].

[^algoWatch]: Algorithm Watch has a [great Article](https://algorithmwatch.org/en/autocheck-guidebook-discrimination/)
with multiple case studies on this topic, and also offers a checklist to reduce the biases in software.

The classical examples for these situations are Human Resources applicant classification algorithms fed with the biased
data of preferably male employees which will transfer these biases into the hiring processes;
or an image recognition algorithm that will not be able to identify people of colour with the same accuracy if it was
fed the predominantly white images.
Of course, examples that are worth mentioning, and far from being solved; but examples a lot of developers already have
in mind. Still, there are many ways a product or service may show bias in situations in which developers are less aware
of possible problems.

One of these situations is neglected product context. A product or service may work without bias in on situation or
target group, but cause unfair outcomes when used under different circumstances.
But bias can be minimal and sublet, like online forms which do assume that a family name has a minimum length or that
there is exactly one (or exactly two) family names, forms which assume a postal code is numeric, forms which assume
certain letters do not exist in names or email addresses - in general, assumptions developers made often without
realising that there are edge-cases in which their desiccation impedes the usage of their web site to some users.

### Ethical Privacy

Have you accepted the cookies for this page? No, you did not. There are no cookies, no trackers, no information I
collect about you, dear reader.
The main reason for this is not that I am not interested in who is visiting this page, instead, I avoid the fuss of
respecting your data ethically and legally.
While this blog does not, a lot of IT business models are based on the collection, classification, and interpretation of
user data. This is nothing bad, it just is the usage of the technology we have often enough with good intentions to
offer services people are consuming.

Collected data becomes an object of ethical considerations if it is misused, its usage is mis-communicated, or if the
data is available to third parties due to the carelessness of the company.

Respecting the person and their digital representation comes with a separation of the data that a company may be able to
collect, data a company needs to collect to provide a service, and data that might be useful for the company but is not
part of its current daily business.
This leads to the question if the company has communicated which data is collected for which reason. Thanks to
over-complicated laws, Terms and Conditions offer a length which feels similar to the modern infinity scroll of
Instagram. What part of the Terms and Conditions do you read? Do you scroll through the settings of any installed
application to switch out any data sharing options? Do you share the crash report if a software on your computer
experienced an unexpected event?

A company may offer the user options to decide which data they want to share, and a company may decide on how clear,
understandable, and accessible these options are. Same holds for information on how the data is used. It's the company's
decision how to present this information to the user.

## So what now?

Takeaway so far: at least I was surprised how often I touch ethical problems without thinking about them when writing
those colourful letters on dark background. But what to do with that feeling of newfound awareness?
The first thing that changed for me is positively or negatively recognize when software, websites, or IT companies
cared about ethical values.
Secondly, I am in a position in which I might be able to change a feature of a software product during its design and
development. I am not in the position to certify or consult a company - pointing to the accountability section - but I
do hold my ground to call out ethical concerns as I encounter them in new features. This is no framework, nor guidelines
but barely personal recommendations.

### Introduce the new stakeholder

In every Feature discussion, there are more stakeholders than visible at first glance. There is the capitalistic
stakeholder asking for short-term revenue, the C-Level asking for long time revenue, the marketing people who want the
feature to fit on an online ad, the motivated tech person who is looking forward to trying out that new technology,
the concerned senior dev who wants their code base clean and tidy. One physical person may function as multiple
stakeholders. With the ethical topics in mind, having one person in such meetings who will play the role of the
concerned activist, or the role of a not digital native who has a hard time understanding how their data will be used,
or the role of a critical thinker who wants to know how the company makes a decision, or the role of a person of a
minority group. A feature is always viewed from a different point of view, take your time to add additional views to
be aware of ethical problems [^ethical aligned design].

[^ethical aligned design]: Ethically Aligned Design, including the book more information about this
process [here](https://ethicsinaction.ieee.org/)

### Know your values

A finance company might value privacy, a company that offers CO2 tracking might value sustainability. Not every company
has the same values, and objectivity of values is a discussion of its own. So take some time to talk about the values
of your company. Talk about the ideas and values of the management and C-Level, about the deal-breaker for developers,
and the ethical standards that you agree upon for your business. Business values do not need to be the same as private
values, there are valid reasons why you as person does not agree with the values of a social network, but as a (
self-chosen) employee, your values should at least align with the company values.

### Talk about and document the company values

Make it a habit to talk about the values, to document the problems you found in a feature. Make a comment above a code
you wrote for an ethical reason or about the danger you expect if that line might be changed. Encourage the discussion
and share blog posts that point out wrong assumptions in programming or UX [^falsehoods]. Provide a space for such
discussions and maybe even support that people educate themselves on such topics.

[^falsehoods]: For your next discussion about validation rules on forms
read [Falsehoods Programmers Believe About Names](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)

### Accept the possibility to stop a feature if it does not fit your values

All of the above does not hold value if you are not able to stop the development of a feature if you can not align it
with the decided company values. Even if some CEO thinks it's a great benefit to misuse user data, or accounting would
go for profit optimisation by selling user data, or some developer would like to keep that cool backdoor they put
in the code for whatever reason.

If you want to check your product or service for ethical problems, but you are not convinced to change something if you
find some; rethink your incentives, because they might be more marketing focused than actually ethical doubts.

## Conclusion

This post is aims to inspire, to sensibilize for stumbling stones that might have been overlooked easily. I
want to encourage the reader to think about values when coding. Because even though it feels like a developer is focused
on the technical problems they solve daily, there are social and ethical problems they should not ignore.

Please feel free to, if you feel curious, have a look the IEEE Standards. The people behind the standards are motivated,
super open for critique, and offer a great set of courses I can only recommend. 

Happy and respectful coding :) 
