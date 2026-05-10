---
title: "Opinions on AI"

date: 2026-05-04T10:20:44+02:00

draft: true

description: "."

tags: [ "Code Quality", "Observability" ]

---

{{< lead >}}
What code complexity can mean — from Big O notation and Cyclomatic Complexity to the surprising
insights psycholinguistics can offer software developers.
{{< /lead >}}

## Science on AI

### What is there to be measured

self reports, experiments, interviews

Time to completion
LLM suggestions acceptance rate
(One reason the acceptance rate metric is widely adopted is a study conducted by GitHub )
Mental effort and cognitive load
Econometric analysis

Benefits
Accelerate software development: Participants
from several empirical studies, particularly those using self-reported methods, suggest that LLM-assistants can
accelerate software development. Found in experiements. But also perceived "stay in flow"

> Minimize online code search: LLM-assistants over searching for solutions via traditional online resources,
> including Q&A
> platforms such as Stack Overflow. state of flow
(e.g., “stay in the flow”), improving the speed of syntax recall, facilitating the discovery of unfamiliar APIs, and
> providing an alternative in situations where online search methods fail to deliver. conducts a study with 44
> participants
> comparing ChatGPT and Stack Overflow across algorithmic problems, library usage, and debugging tasks, finding
> higher-quality outputs for ChatGPT in algorithmic and library tasks, while Stack Overflow performs better for
> debugging,
> with no statistically significant difference in task completion time

> Automate trivial/ repetitive tasks. reduces trivial tasks by generating boilerplate code and tests

> Support knowledge acquisition, Professional developers increasingly perceive these tools as a valuable aid for
> learning
> and knowledge
> acquisition

> Support codeadjacent tasks. Developers also use LLM tools for composing emails, generating meeting minutes, and
> creating
> onboarding
> documentation

> Reduce task initiation overhead. proof-of-concept applications by generating multiple candidate implementations
> for the
> same task [PS11] generating an initial structure
> when starting new topics

> Improve code quality. Their
> findings indicate that three of the five teams experience a measurable reduction in code smells, and all five teams
> show a decrease in the number of software defects following the integration of LLM-assistants

> Support debugging/ troubleshooting: Additionally, several
> developers report that LLM-assistants accelerate the debugging process, by enabling faster bug identification and
> early
> defect detection by recognizing patterns and errors that developers may miss at manual check

DOWNSIDES

> Fail to meet requirements. Developers acknowledge that not all the suggestions of LLM-assistants are accurate. For
> example, 50% of participants report missing or misunderstanding the requirement context

> Promote over-reliance and cognitive offloading.encouraging users to understand the tools’ capabilities and
> limitations.
> Finding the right balance between leveraging AI
> support and maintaining developer competence remains an open challenge

> Disrupt the flow. Issues that impact
> developer state of flow have been attributed to various kinds of interruptions, including unwanted LLM suggestions
[PS33], interface switching, and verbose answers

> Limit code quality. Code quality issues arise when developers overestimate the
> capabilities of such tools, which can introduce vulnerabilities and bugs. LLM-assistants often struggle with
> optimization
> and refactoring tasks, especially when lacking semantic context. Hallucinations remain a persistent concern

> Reduce team collaboration. observes that excessive use of LLM-assistants
> may lead developers to favor consulting a chatbot over a colleague. In fact, the overconfidence of LLM-assistants’
> responses can create the impression that team discussions are unnecessary, reducing opportunities for communicative
> learning and discovery

SPACE framewrok
Dimension Sub-dimensions Primary Studies %

Satisfaction
Developer experience
Self-efficacy
Trust
Cognitive load
Performance
Quality
Impact
Activity
Communication
Human-LLM collaboration
Human-human collaboration
Efficiency
Temporal efficiency
Interruptions and flow
Automation

[^systematic_review] : The Impact of LLM-Assistants on Software Developer Productivity: A Systematic Review and Mapping
Study (2026) https://arxiv.org/pdf/2507.03156

> Context agent.md files:
> LLM-generated context files increase cost and reduce
> performance LLM-generated context files cause performance drops in 5 out of 8 settings across SWE-BENCH
> LITE and AGENTBENCH (see Figure 3). In more detail,
> the average resolution rate is reduced by 0.5% and 2% on
> average on SWE-BENCH LITE and AGENTBENCH, respectively. Meanwhile, the context files increase the # steps
> in every setting on average by 2.45 and 3.92 steps, respectively, which leads to a cost increase of 20% and 23% on
> average, respectively We find that all context files consistently increase the number of steps required to complete
> tasks. LLM-generated context files have a marginal negative effect on task success rates, while developer-written
> ones provide a marginal performance gain.
> Our trace analyses show that instructions in context files
> are generally followed and lead to more testing and a
> broader exploration, however they do not function as effective repository overviews. Overall, our results suggest that
> context files have only marginal effect on agent behavior,
> and are likely only desirable when manually written.

PLANNING mode [^planning_mode]

[^planning_mode]: Evaluating Plan Compliance in Autonomous Programming Agents (2026) by Shuyang Liu, Saman Dehghan,
Jatin Ganhotra, Martin Hirzel, Reyhaneh Jabbarvand. https://arxiv.org/pdf/2604.12147

[^no_md_files]: https://arxiv.org/pdf/2602.11988

[^study_on_ai_genereted_code]: https://arxiv.org/html/2603.28592v1

Layer 1: Pretraining (the deepest layer)
During pretraining, a model is exposed to vast amounts of text, learning grammar, facts, reasoning patterns, and more —
but without yet knowing how to follow instructions or behave in a goal-directed way. Crucially, this includes huge
amounts of human-written text about how to solve problems — code reviews, GitHub issues, tutorials, documentation, Stack
Overflow threads. The model implicitly absorbs common problem-solving workflows from all of this. This is what the paper
refers to when it says agents have "workflows internalized during training" — these internalized workflows are often
incomplete, overfit, or inconsistently applied, because they were never explicitly taught as plans; they just leaked in
through exposure. Dextra LabsarXiv
Layer 2: Fine-tuning / RLHF (the alignment layer)
After pretraining, models enter a fine-tuning phase followed by a feedback-driven process that shapes how they actually
behave. The most widely used approach is reinforcement learning from human feedback (RLHF), where people evaluate model
outputs and those preferences get baked into the model's behavior. For coding agents specifically, this often means
training on trajectories of successful task-solving — teaching the model that certain sequences of actions (navigate →
reproduce → patch → validate) lead to good outcomes. Over many such examples, these sequences become the model's default
problem-solving strategy. IBM
Layer 3: Prompting at inference time (the surface layer)
On top of all that, you can give the model an explicit plan in the system prompt or user message. This is what the paper
studies: how well does a model actually follow the plan you hand it, versus defaulting to what it learned in layers 1
and 2?

2. The Core Tension the Paper Exposes
   The paper's central finding is that these three layers can conflict. Each task has a "Goldilocks" frequency for
   planning that clearly outperforms naive strategies of always planning or never planning. When you give a model a plan
   that aligns with its internalized workflows, things go well. When they clash, the model partially ignores your plan
   and falls back on its training — which is why a subpar plan hurts performance even more than no plan at all: the
   model gets pulled in two directions at once

It matches the model's instincts. The standard navigate → reproduce → patch → validate order works because it mirrors
the logical flow a developer would follow — and it's also what the model was trained on. Planning has become a common
design choice in agentic frameworks, usually encoded as step-by-step instructions in the system prompt. When the written
plan matches the model's trained instincts, the two reinforce each other. Vague or poorly ordered instructions are worse
than no instructions. If you're not sure how to structure your request, a minimal clear prompt likely beats an elaborate
confused one.

THE GITCLEAR STUDY [^gitclear]

[^gitclear]: AI Copilot Code Quality - Evaluating 2024's Increased Defect Rate via Code Quality Metrics
https://gitclear-public.s3.us-west-2.amazonaws.com/GitClear-AI-Copilot-Code-Quality-2025.pdf


> 2024 marked the first year GitClear has ever measured where the
> number of “Copy/Pasted” lines exceeded the count of “Moved” lines. Moved
> lines strongly suggest refactoring activity. If the current trend continues, we believe it
> could soon bring about a phase change in how developer energy is spent, especially
> among long-lived repos.

> This graph shows that for every 25% increase in the adoption of AI, their model
> projects a 7.2% decrease in “delivery stability.” But Google does not have hypothesis on the cause of ascendant
> defects.
> In fact, they describe it as “surprising,”
> since developers opinion of AI is mostly positive:
> Given the evidence from the survey that developers are rapidly adopting AI,
> relying on it, and perceiving it as a positive performance contributor, we found
> the overall lack of trust in AI surprising.
> To Google researchers, they see AI adoption increasing, and they see developers
> reporting greater productivity, and so the decrease in quality is interpreted as
> unexpected.

The study's core argument is a compounding problem:

AI makes it easy to generate new code fast, so developers add more lines rather than reusing existing ones
That new code often duplicates existing logic (the 8x rise in duplicate blocks)
Duplicate code means bugs need to be fixed in multiple places — and often only get fixed in one
Less refactoring means the codebase never gets simplified, so complexity compounds over time

One thing worth being skeptical about though: the study can't fully separate AI causing this from the kinds of projects
that adopted AI early happen to be fast-moving greenfield work where copy-paste is more natural anyway. Correlation vs.
causation is a real gap here.
This actually makes the churn data more coherent than the study's framing suggests. The relatively flat 2022 and
moderate 2023 numbers make sense — Copilot was available but not yet widely used at scale. The dramatic 2024 spike
aligns almost perfectly with Cursor's explosive growth and Copilot's enterprise rollout.

BUGS IN THE CODE FROM AI

> Halluzinations: Particularly notable: LLMs may add a non-prompted feature to the code, leading to an error, something
> that a human developer would rarely do, which shows that LLMs bugs might not be exactly similar to human-made bugs.

> Code smells: This is precisely what GitClear is measuring at scale — the macro-level signal of refactoring dropping
> from
> 25% to under 10% and code cloning rising from 8.3% to 12.3% is the aggregate footprint of bucket-3 errors leaking into
> production.

Mechanism 1 (what the study directly shows): bug-prone contexts trigger memorized buggy completions. When the
surrounding lines match a pattern that exists in training data near a known bug, the model is drawn toward reproducing
that bug. The "badness" isn't necessarily visible in the surrounding lines — it's that those lines happen to resemble
the lead-up to a real historical bug the model saw during training. The trigger is statistical similarity to bug-prone
training examples, not an aesthetic judgment of "this code looks bad."
Mechanism 2 (a related, weaker effect from other studies): low-quality surrounding code shifts what "looks idiomatic" to
the model. If your file is full of unsafe patterns, weak typing, no error handling, and copy-pasted blocks, the model's
notion of "what the next line should look like here" shifts toward matching that style. This isn't about memorized
bugs — it's about pattern continuation. Models complete in the style of what surrounds them. So if the surrounding code
skips input validation, the next function the model writes will probably skip it too. If the codebase uses an outdated
unsafe API everywhere, the model will keep using it.

MORE BUGS

Code Volume & Bug Rates
> The clearest numbers come from Google's own 2025 DORA Report. A 90% increase in AI adoption was associated with a 9%
> climb in bug rates, a 91% increase in code review time, and a 154% increase in pull request size.
> Increased complexity: Cyclomatic Complexity, a metric correlated with maintenance difficulty, is generally higher in
> LLM-generated code. Since AI increases Lines of Code, Halstead Metrics, and Cyclomatic Complexity, the resulting
> increase of maintainability issues confirms the rising accumulation of structurally weak code.

[^dora]

[^dora]: https://services.google.com/fh/files/misc/2025_state_of_ai_assisted_software_development.pdf

[^open_source]: https://metr.org/blog/2026-02-24-uplift-update/

LEGAL things

1. The Core Rule: AI Must Not Impersonate HumansThis is the clearest and most universal requirement. AI designed to
   impersonate humans (e.g. a chatbot) must inform the human it is interacting with that they are talking to AI.
   EUR-LexThis applies in multiple jurisdictions:EU (Article 50 of the AI Act): Users must be informed when they are
   interacting with an AI system, not a human, unless this is obvious from context. The disclosure must be made at the
   point of first interaction.
2. AI Act — The Most Comprehensive Framework
   Since you're in Germany/the EU, this is your primary concern.
   The prohibitions and AI literacy obligations entered into application from February 2, 2025. Governance rules and
   obligations for General Purpose AI (GPAI) models became applicable on August 2, 2025. Rules for high-risk AI
   systems have a transition period until August 2, 2026 (potentially extended further). European Commission
   As a developer/deployer, Article 50 hits you now:
   Providers of AI systems directly interacting with natural persons must design and develop those systems so that
   users are informed they are interacting with an AI system. Providers of generative AI systems must mark AI
   outputs in a machine-readable format and ensure they are detectable as artificially generated or manipulated.
3. Data Privacy: GDPR Still Applies
   Existing data protection law doesn't pause for AI. GDPR mandates a legal basis for processing personal data and gives
   individuals rights like access and erasure — requirements that clash with an LLM's tendency to ingest and obscure
   personal data. HIPAA demands strict safeguards for Protected Health Information; feeding patient data into an AI
   model or third-party API could constitute a breach if not properly protected and logged. Medium
   If your LLM app processes personal data of EU residents, you need a lawful basis, a data processing agreement with
   your AI provider (e.g. Anthropic, OpenAI), and to think carefully about data minimization.
4. AI-generated output: AI-generated works lack copyright protection under current law, as they are not human
   creations — meaning such output is in the public domain. This matters if you're trying to protect AI-generated code
   or content you produce.

EU ACT
Unacceptable risk (banned outright): Social scoring by governments, real-time biometric mass surveillance in public
spaces, subliminal manipulation. These prohibitions have applied since February 2, 2025. European CommissionHigh risk:
AI in hiring/HR, credit scoring, education, healthcare, law enforcement, border control, critical infrastructure.
Requires conformity assessments, documentation, human oversight, and registration in an EU database.Limited risk (your
main concern as an LLM developer): Chatbots, deepfakes, generative AI — subject to transparency and disclosure
obligations.
