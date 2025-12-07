---
title: "Looking at Observability"

date: 2025-11-30T10:20:44+02:00

draft: false

description: My learnings about monitoring, alerting and observability in software systems.

tags: [ "Metrics", "Observability" ]
---

{{< lead >}}
I have spent some time pushing the monitoring and alerting in the team I am currently working away from users reporting
incidents, to monitors to observe the current state of the system and alerting before users find issues severe enough to
report. This blog post summarizes some of the key concepts and best practices I have learned along the way.
{{< /lead >}}

## Three pillars of observability

> Raw data is a oxymoron, there always decisions made what to collect and how to store it. (Pydata 25 Melbourne, "
> Falshoods Devs beliebe")

Observability starts with collecting data about the system. The three pillars of observability are the main three ways
in which data may be collected. [^DataDogTraining]

[^DataDogTraining]: A four times two-hour training by DataDog I joined in October 2025.

* **Logs** - timestamped, semi-structured text records of discrete events, like error messages, transaction records,
  user actions. Mind that power of logs comes from their structure, the inclusion of meta-data like request IDs, request
  type, user group, trace id,... makes logs much more useful to search and to correlate. Compared to events, logs are
  more flexible and allow for more experimentation to find the right structure. Mind that logs should never contain
  sensitive data.
* **Metrics** - numerical data points collected over time, like request latency, error rates, business cases processed.
  They are an efficient way to monitor the health data over time, and can be aggregated and visualized in dashboards.
  While logs often are limited to some recent time window, metrics can be stored for longer periods to analyze trends.
* **Traces** - A static trace id in a request can be used to track a request life-cycle across multiple components.
  Traces are useful to understand the flow of requests, identify bottlenecks, and debug issues in complex
  distributed systems.

### Why Monitoring and Observability?

There are many reasons why monitoring and observability is important for software systems, I would emphasize:

* Operation: Understanding the current state of the system
* Alerting: Fast detection and resolution of incidents
* Working Datadriven: Being able to conduct experiments and measure their impact

## What to Log?

### Service Level Indicators (SLIs), Service Level Objectives (SLOs) and Service Level Agreements (SLAs)

**Service Level Indicators (SLIs)** measures on service level, for example request latency, availability, throughput.
Which indicators are important to a system depends on what the users care about.

{{< alert "comment" >}}
Mind the Users Perspective: Different users care about different indicators, depending on their use case.

A human facing Web Service might care about _Does the service response (Availability)? How long does it take to
respond (Latency)? Does it respond without errors (Error Rate)?_.

A Data Pipelines might care more about _How long does it take to process data (End-to-end-latency)? How much data
can be processed (Throughput)? Is the data correct (Correctness)?_.
{{< /alert >}}

**Service Level Objectives (SLOs)** are target values or ranges for a service level indicator over a period of time or
fraction of requests, like 99.9% of requests should be below 100ms latency, or 99.9% availability over a month.
Choosing and publishing SLOs can communicate expected performance to users, and can guide developer decisions.

**Service Level Agreements (SLAs)** are explicit or implicit contracts between service providers and users.
Explicit SLAs can be legally binding requirements, while implicit SLAs are expectations of the users.

A special form of SLA is the error budget, which defines for developers how much unreliability is acceptable within a
certain period, until developers need to focus on reliability improvements over feature development.

### Choosing what to monitor

The golden signals are a good starting point for choosing what to monitor: [^SideReliabilityEngineering]

* Latency - Time to process a request
* Traffic - Amount of requests
* Errors - Rate of failed requests
* Saturation - Resource utilization with focus on bottlenecks

Additionally, business relevant metrics should be monitored. These should reflex both the users perspective and the
business goals. For a data pipeline, this could be volume of processed data, the quality of the data sources, or the
quality of the output data.

Besides talking to users and stakeholders, it is very useful to include the monitoring into the post-mortems of
incidents. Which indicator would have helped to detect the incident earlier or identify the root cause faster?

**First principles** are basic assumption about the system that are not deduced from other assumptions.
The idea of first principles is usefully as good observability should allow a developer to debug a system without a lot
of prior knowledge about it. As software systems grow in complexity, it becomes more valuable to have a solid foundation
to reason on facts rather that relying on years of experience with a system. [^ObservabilityEngineering]

[^ObservabilityEngineering]: [Observability Engineering](https://learning.oreilly.com/library/view/observability-engineering/9781492076438/)

## Alerting and Monitoring

Assuming there are metrics and logs collected about the system, anomalies need to be detected and acted upon.
There are three main ways to deal with anomalies: [^SideReliabilityEngineering]

* **Collecting** information about anomalies that do not require action. For example, higher load on mondays morning is
  a good thing to be aware of, but not something that needs action.
* **Tickets** can be created for anomalies that need to be investigated, but do not require immediate action. For
  example, an increased error rate for one user group.
* **Alerts** are created when immediate action is required and possible. If the throughput of a data pipeline drops
  below a certain threshold, an alert can notify to investigate and mitigate the issue.

Alerts should be designed carefully, as they create cognitive load for developers and operators. The worst alert are
repeatedly false alarms, alarms on which no action can be taken, or constant alarms that are ignored over time.

### Alert Design

An alert should be actionable. It should be common practice to define runbooks for every alert. What are possible
causes, and how to investigate, and how to mitigate the issue? Information like who will be notified, escalation paths,
or user impact should also be part of the runbook. Alerts should also require intelligence to investigate - if the
runbook looks so well-defined, that it can be automated, it should be.

### Choosing Targets for Alerting

Externally Service Level Indicators (SLIs) do not need to match internal alerting targets.
If the external targets are higher than the current (sub)system performance, alerting will be frequent and therefore
ignored in the long run; and if the external targets are lower than the current (sub)system performance, alerts can be
used to strive for higher performance.

[^SideReliabilityEngineering]: Side Reliability
Engineering - [Google SRE Book](https://sre.google/sre-book/table-of-contents/)

## Using Dashboards

Observability should enable developers to understand and debug the system. Dashboards and Monitors should be designed
around usability - next to the alert that some request time is out of bounds, developers should be able to quickly find
information about possible causes, like request rates spiking, database connections being exhausted, or error rates
increasing. Looking at a dashboard full of flashing graphs is not useful, even if it might look impressive.

### Distribution over Averages

Data viewed in distribution reveals patterns, anomalies, and offers more actionable insights compared to simple
averages. For example, the average response time of a web service is nice to have, the information that 95% of requests
are below 200ms while 5% take over 2 seconds provides a actionable insight that can lead to performance improvements or
clearer expectations for users.
Software system often have non-normal distributions, with outliers and long tails that would be hidden by averages, but
are visible by using distribution aware tools like percentiles. [^SideReliabilityEngineering]

{{< alert "pencil" >}}
**k-th Percentiles** are a statistical tool to express the value or score point below which a given percentage **k** of
the data points fall. For example, a 95th percentile latency of 300ms means that 95% of requests are served in under
300ms.
{{< /alert >}}

Distributions is not limited to distribution over amount of data points, but can also be used to show distribution over
time, resources, user groups, ...

* 95% of requests are served in under 200ms
* On 95% of days, the response time was under 200ms
* 95% of our users in the low-data throughput group experienced response times under 200ms
* 90% of our containers served requests in under 200ms

This already hints at what meta-data is useful to collect alongside the primary metrics.

### Dashboards like Medical Monitors

Ever looked at a medical monitor with heart rate, blood pressure, oxygen saturation and wondered if the values are good
or not? Reading ECG requires training and experience, knowledge about the p-wave, qrs-complex and t-wave, and what how
specific patterns indicate health issues.
The moment a health metric drops or rises above a certain threshold, the monitor will indicate that by a color change, a
easy description (e.g. "HR low"), and an alarm sound that fits the severity of the issue. This enables medical staff to
act fast, without needing to interpret the raw data to understand the situation, and without knowledge about the type of
monitor.

If you think about dashboard designs like medical monitors, the time series data requires a lot of training and
experience to read, and while it can be interesting, it is often hard to judge what is normal and what is not.

Dashboards should therefore include baselines, indicating what is normal for a metric:

* Display a shaded area around the time series, indicating the average over the past weeks
* Provide high and low thresholds for normal ranges
* Color indications when the metric is outside normal ranges with severity levels
* For every numerical metric, provide the average metric over the past weeks as a reference point
* Provide context about external factors that influence the metric, like deployments, incidents, marketing campaigns,
* Have meaningful titles, and add hints, explanations, links to runbooks to help interpreting the data

