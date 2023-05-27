---
title: "Welcome to Semgrep Code Intelligence"
date: 2023-05-27T20:30:59+02:00
lastmod: 2023-05-27T20:30:59+02:00
draft: false
author: " Tit Petric"
authorLink: "https://github.com/titpetric"
description: ""
license: "MIT"
images: []

tags: []
categories: ["Semgrep CI"]

featuredImage: ""
featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
ruby: true
fraction: true
fontawesome: true
linkToMarkdown: true
rssFullText: false

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
math:
  enable: false
  # ...
mapbox:
  # ...
share:
  enable: true
  # ...
comment:
  enable: true
  # ...
library:
  css:
    # someCSS = "some.css"
    # located in "assets/"
    # Or
    # someCSS = "https://cdn.example.com/some.css"
  js:
    # someJS = "some.js"
    # located in "assets/"
    # Or
    # someJS = "https://cdn.example.com/some.js"
seo:
  images: []
  # ...
---

Hello, my name is Tit Petric. I'm a Senior Engineer working on Go code at
[Tyk Technologies](https://tyk.io). I'm working on back-end code for the
open source [Tyk API Gateway](https://github.com/TykTechnologies/tyk) and
the [Tyk Dashboard](https://tyk.io/docs/tyk-dashboard/) API management
product.

I've started the Semgrep Code Intelligence project to collect test
utilities, toolings, reports, code review feedback, experiments and other
development efforts aimed to improve the process around development and
the overall vibe of the codebase. Knowing what to fix requires knowing
what is there and how it's coupled.

<!--more-->

This blog has three main focus areas:

1. **Enhance code quality**: The blog focuses on best practices for the Go
programming language. We will identify and rectify common code defects,
improving the overall quality and reliability of your projects.

2. **Practical code refactoring**: Gain practical insights into code
refactoring techniques. We will see real-world examples that demonstrate
how to improve code readability, maintainability, and performance,
ensuring your Go codebase remains clean and scalable.

3. **Leverage Semgrep**:  Discover the benefits of Semgrep, a robust
static analysis tool. Dive into examples showcasing how Semgrep can
assist in detecting code issues and facilitating large-scale code
changes, making your development process smoother and more efficient.

I'll be covering improvements towards these goals. I aim to document a
collection of code review feedback with examples of code snippets and
semgrep rules to detect and fix issues.

In practice, I want to introduce a domain driven design structure to the
gateway and dashboard, improve how we test code with [locality of
behaviour](https://htmx.org/essays/locality-of-behaviour/), and enable a
good structural foundation for existing and future work.

If I've learned anything, it's very hard to teach people to write good
code, harder to teach them to detect bad code, and very hard to teach
them to fix it. I suppose writing good code should be pretty easy these
days, but it's common to join a company and inherit legacy with defects
that can and should be addressed without going into a full rewrite.

Code intelligence goes beyond just what we can measure with semgrep, and
we'll look at custom code intelligence tooling. Test suites contain a
treasure trove of data to surface the state of the code, and there are
many automation opportunities to surface actionable warnings from code
changes.

Welcome!
