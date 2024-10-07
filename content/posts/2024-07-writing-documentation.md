---
title: "Writing useful Documentation"

date: 2024-10-06T10:20:44+02:00

draft: false

description: Exploring useful, well written, up-to-date documentation to get away from the outdated mess.

tags: [ "Development", "Agile" ]
---

{{< lead >}}
Docs, or it didn't happen.
{{< /lead >}}

Documentation can determine how fast new developers can be onboarded, how easy consumers can answer their questions, and
can serve as public communication point between team and product or other teams - it is both time saver and opportunity
provider. It may be well-structured, even interesting to read, the start of discussion points for feature development,
consumed for automation (like Open Api files), or on the other hand, it can be a mess of outdated information.

## The Readers Perspective

Documentation is always written for somebody and to answer their question - not the curiosity of the writer.

- **Know Your Audience** : Define audience by roles with certain knowledge. For example, a developer that just
  started in the company; a backend developer of a different team; a product owner ...
- **Understand the Audience's Needs** : What do they want? Meeting the needs of the audience is the primary goal of
  documentation.
- **Know what you want from the audience** : Do you need them to make decisions? Do you want them to understand the
  system? Do you want them to use the system?
- **Understand the Audience's Knowledge** : Experts often suffer from the curse of knowledge, which means that their
  expert understanding of a topic ruins their
  explanations to newcomers. What is their technical understanding? What is their domain knowledge? What
  diagrams can they understand?

The best documentation is written by a person with empathy for their audience. Understanding the audience is key to
communication. How much does the audience know about the topic? Does the audience know about similar topics, which
analogies can they understand? Does the audience know the stated, but hasn't used the knowledge since some time? Does
your audience have out of date knowledge? What is the audience's motivation to read the documentation? What does the
audience need to learn to accomplish their goal? Does the audience need to act in a certain order?  [^patterns]

{{< alert "circle-info" >}}
Written communication holds all the complexity of spoken communication. Humans will always interpret the text, and will
resist any message if they think their needs are not understood. Dropping empathy in business communication is not
constructive, demonstrating understanding and alignment of goals is. Persuasion is progress.
{{< /alert >}}

For every audience, the documentation should follow a **narrative**. When deciding on the structure of a documentation (
and even the structure of each diagram or chapter in it), consider drafting a narrative as guidance.
Example narratives could be **a Success Story** how a solution was implemented successfully, **a Failure Story** how a
solution failed and what lessons were learned, **a Use Case** a visualisation on how the system is used, **a Clarity
Story** to expain why a decision was made.

### Accessibility

**Accessibility is Inclusiveness** : The curb cut effect describes how designing for accessibility benefits everyone.
Originally, curb cuts (sidewalk ramps) were designed for people in wheelchairs. However, many people benefit from curb
cuts, such as anyone with a stroller, suitcase, or delivery cart. [^google]

Accessibility in documentation means that the documentation is usable by everyone, including people who are colorblind,
using an uncommon screen ratio, who have problems reading unstructured text due to neurodiversity, or have any other
form of impairment possible in the audience. Things to consider could be: [^patterns]

* Do not rely on color alone to convey information (additionally form, text, or symbols). Pay attention to contrast and
  color choices in pictures or diagrams. Use tools like [Color Oracle](https://colororacle.org/)to simulate color
  blindness.
* Mind the device that the audience is using. Especially for phones or screen readers using tables can make the
  information harder to access.
* Structure the text using linkable headings. Use paragraphs for related ideas, and use the first paragraph in a chapter
  to communicate the main idea, as readers pay more attention to the first paragraph. Use Clear language (easy to read,
  listen to, and translate)
* Provide an alternative text for images that explain images in the context of the text.
* Use Inclusive language and examples.

**Keep your writing culturally neutral** : "Piece of cake" and "Bob's your uncle" are culturally specific idioms that
can only be understood by people from certain cultural backgrounds.

{{< alert "circle-info" >}}
Accessibility also refers to the availability of skills of the audience. When there is only a subset of people that
can read UML Diagrams, that parts of documentation are not accessible to the whole audience. If there are even less
people who can write UML Diagrams, the documentation is prone to become stale.
{{< /alert >}}

### Feedback loops

Get feedback early and often from multiple audiences. Get feedback on small parts as well as the overall design.
Identify errors and misunderstandings early, when they were not yet repeated in the documentation. Ensure alignment with
business. Identify risks and challanges early. [^patterns]

**Establish a dialogue with the audience**. Documentation can have a formal pull request process, scrum reviews can also
present documentation.

Focus your feedback requests on useful and representable picks of the audience. Generic feedback is not helpful, but
regular contact with the audience can help to understand their needs and to adjust the documentation to them.

## Technical Writing

### Terminology

Naming things is hard. Every project should take away one thing from Domain Driven Design - the ubiquitous language that
is shared between developers and users, and listed in the documentation. The language should be consistent, as simple
and precise as possible (like `invoiceSum` instead of `commutativeTotalSum`), best if the terms are "googleable".
Consider that some part of the audience are using a translation tool, using simple language avoids translation errors.
When possible introduce (or link to the glossary) new terminology in the beginning of the paragraph that rely on
them. [^google]

While one central point "glossary" for the ubiquitous language can help the users and the developers.

Acronyms should be avoided. They do not provide any benefits, but only the opportunity for misunderstandings.

### Writing Style

[^google]: [Google Technical writing courses](https://developers.google.com/tech-writing/overview)

The first paragraph of a Documentation page should state the audience, topic and goal of the page.

**Answer what, why, and how** : Good paragraphs answer these three questions:
What are you trying to tell your reader?
Why is it important for the reader to know this?
How should the reader use this knowledge? Alternatively, how should the reader know your point to be true?

> **Minto Pyramid Principle** The easiest order for a reader is to receive the major, more abstract ideas before he is
> required to take in the minor supporting ones. And since the major ideas are always derived from the minor ones, the
> ideal structure of the ideas will always be a pyramid of groups of ideas tied together by a single overall
> thought.[^minto]

[^minto]: Barbara Minto about the Pyramid Principle. Citation copied from "Communication Patterns by Jacqui Read"

* Adopt a style guide
* Replace this or that with the appropriate noun.
* Prefer active voice to passive voice `The Code is interpreted by Python, but the code is compiled by C++` vs
  `Python interprets the code, but C++ compiles the code`
* Reduce there is / there are
  `There are setences starting with "there is" or "there are" that should be avoided or rewritten to replace the generic topic with a more specific one`
  vs
  `Sentences starting with "there is" or "there are" should be avoided or rewritten to replace the generic topic with a more specific one`
* **Keep it short** - Shorter documentation reads faster. Focus each sentence on a single idea and break up long
  sentences into lists.xf

### Diagrams

An audience should be guided from high abstraction to detailed information, using diagrams with intention and without
clutter. [^patterns]

**Keep the Abstraction level consistent** : Levels of abstraction refer to the granularity of the information presented.
Mixing abstraction levels can confuse readers, and depending on the audience turn a diagram unreadable.

{{< alert "circle-info" >}}
**C4 Model Hierarchy of abstraction** describes the four levels of abstraction for software architecture diagrams:

* Context Level Diagrams show the system in its environment
* Container Level Diagrams show the high-level structure of the system
* Component Level Diagrams show the components inside the containers
* Code Level Diagrams show the implementation inside the components
  {{< /alert >}}

**Representational Consistency** : When the audience is navigating between diagrams of different levels of abstraction,
it should be easy to understand the relationships between the diagrams. Consistency in naming, style, and added
container / component boxes should guide the reader and reduce cognitive load.

**Purposeful Styling** : Colors can be used to highlight important information, but they should be used with the
intention to provide an extra level of information (like categories, or status). Same goes for shapes and lines. Styling
a box in a sketched way can indicate that the component is not yet implemented and can again add an extra level of
information.

**Simplify the geometry** : The excessive use of boxes, relationships, and lines can make a diagram unreadable. A good
starting point can be to make a diagram symmetrical with non-crossing, uni directional lines. If you do not want to
communicate something particular, all similar objects should have the same size. A good abstraction may
redesign reality like subway maps are an abstraction stripped by the reality of a city map to make it more readable and
understandable. Relationships can be of hierarchical, sequential, causal, proportional (scale) or spatial (relative
position) nature.

**Include a legend and labels** : Labels should be placed if they help the audience to understand the message of the
diagram, and be moved to a legend or note if not. Similar to a coder naming a function or variable to avoid a comment,
the message of a diagram should be explicit by composition, component, and labels.

**Utalise the audiences expectations** : Match the diagram to expectations (of content, shapes, and flow). from
left-to-right, top-to-bottom,
with start of information in the top left corner, and the end in the bottom right. The audience may also expect certain
shapes to represent certain things.
Like a narrative, the diagram should have a beginning with which the audience starts reading, a middle, and an end with
a result or conclusion.

**Single Responsibility Principle** : A diagram should have a single purpose to effectively comm unicate a single
message. It should either describe the behavior of a system or the structure of a system. Structure diagrams communicate
what and where, visualising relationships or physical location of hardware. Behavior diagrams communicate how and whom,
visualising the flow of data or state changes.

**Example Code should work** : Example code should perform the task it claims to perform and be as production-ready as
possible. Language-specific conventions should be followed.

[^patterns]: [Communication Patterns by Jacqui Read](https://www.oreilly.com/library/view/communication-patterns/9781098140533/)

### Structure

**Product over Project** : A project is a temporary endeavor with a defined beginning and end, while a product is
something that is ongoing and has a lifecycle. Documentation should be written for products, not projects.

A Product Mindset comes with a long term view, and a focus on the customer. Collaboration and reusability will benefit
on product centered documentations, especially with more than one team working on a product, or products that witch
switching teams. The documentation can a holistic view of a product not a snapshot of a project.
Consistency across products can emerge from templates and shared best practices.

**Use Metadata** : Metadata can be used to structure the documentation, and to provide context to the reader. It may
contain tags to categorize the documentation, a version number, a date of last update, or a list of contributors or
responsible team.

**Perspective Driven Documentation** : A pattern that focuses on Perspectives, a collection of one or more artifacts
that address one (or multiple related) concerns of a particular audience. One key principle is to no repeat information
and use links and references instead. Perspectives are fractal and can be embedded into other perspectives. An example
for this can be layered diagrams, which respond to different perspectives of different audiences depending on the

**Just in Time Documentation** : "You are not gonna need it" is a development principle to only implement functionality
that is needed not to avoid overengineering for use cases that never come. A principle that can be applied to
Documentation and Knowledge management. This encourages faster, more efficient working on a more up-to-date
documentation that is clear of fortune told waste pages, written document pages that are lost and never used. There can
be a place to record information that could be relevant in the future.

**Use Architecture Design Records and document Architecture**: Document architecture decisions, reasons, and future
risks in the code base using ADRs (which I explained also in
[this post about team communication]({{< ref "posts/2023-04-communicating-between-teams" >}}). Architecture can also be
documenting by recording Architecture Characteristics (discussed in
[this post about agile architecture]({{< ref "posts/2024-05-agile-architecture" >}}) or by following evolutionary
architecture and document decisions via fitness functions (discussed in
[this post about Evolutionary Architecture]({{< ref "posts/2024-09-evolutionary-architecture" >}})

**Company-wide Documentation** : Documentation does not only exist in the context of a product. It should be searchable
and accessible throughout the company where needed, if possible with the company-wide wiki or knowledge management tool.
Also, there are documentation types about the company, like a tech radar, or how to things work around the company (from
using HRs "products" like how to access educational resources and of course the companies platform tools).

## Testing and Automating Documentation

**Documentation as Code**
Documentation should be created, updated, and live in the same environment (e.g. IDE) as the code it describes. This
allows easier workflows, utalises existing review processes, better discoverability, enabled collaboration, and
automation.

**Automating Documentation Publishing** : Not every audience is able to read documentation from the code base. Subsets
of the documentation should be readable from outside the team or even the company. This can be enabled by providing an
endpoint which always returns the current state of the Open Api File which is based in the code base. But it can also
mean syncing parts of the markdown documentation files to other documentation systems like syncing the glossary to
Confluence.

{{< alert "circle-info" >}}
I made perfect experiences writing the glossary as code, matching it to class and variable names, and ensuring a
developer wrote and one reviewed the description; and syncing it to confluence to provide visibility and exchange with
management or product.
{{< /alert >}}

**Generating Documentation** : Generating documentation should be used with care. Using AI to generate documentation
especially, as AI tools are still in their infancy. But generating selected parts of the architecture can be very
helpful and ease keeping the docs up to date; like generating a state graph out of the events and handlers in an
event-driven architecture.

{{< alert "circle-info" >}}
Especially with generated Open Api Files I did make unpleasant experiences which is why I would suggest consumer facing
documentation to be written by hand. But it can help a lot to either generate code based on the Open Api file, or to
[test the implementation against the expected Open Api File]({{< ref "posts/2023-03-testing-open-api-specs" >}}).
{{< /alert >}}

## Conclusion

Documentation is a key part of the development process. It should be written with empathy for the audience, with care,
with a spark of creativity.

Happy documenting :)
