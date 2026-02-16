---
title: "Functional Python"

date: 2026-02-01T10:00:00+00:00

draft: true

description: ""

tags: [ "Agile", "Devops" ]

---

{{< lead >}}

{{< /lead >}}

## Functional Programming

## Functional Python

When I was in university I took a course at the University of Oslo "Biological Inspired Computing" - one of my favorite
courses. It covered many interesting algotithms (still remember Ant Colony Optimization and Genetic Algorithms 💜) but
also neural networks. I had way too much fun implementing the Forward phase of "The Multi-layer Perceptron Algorithm"
only using list comprehensions in Python.

{{< katex >}}

$$
hiddenNote_i = \sum_{i=0} x_{i} v_{i\zeta}
$$


```python
hidden_layer_result = [(sum(x*v for x,v in zip(inputs, weight))) for weight in level_1_weights]
```

### List Comprehensions

