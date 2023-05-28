---
title: "LSC - Large scale code changes"
date: 2023-05-28T10:30:59+02:00
lastmod: 2023-05-28T10:30:59+02:00
draft: false
author: " Tit Petric"
authorLink: "https://github.com/titpetric"
description: ""
license: "MIT"
images: []

tags: []
categories: ["Go", "Semgrep"]

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

First, there's some essential reading in the excellent
[Google SWE Book: Large-Scale Changes](https://abseil.io/resources/swe-book/html/ch22.html)
chapter. A key point being brought up by Adam Bender:

> Today it is common  for a double-digit percentage (10% to 20%) of  the
changes in a project to be the result of LSCs, meaning a substantial
amount of code is changed in projects by people whose full-time job is
unrelated to those projects. Without good tests, such work would be
impossible, and Google’s codebase would quickly atrophy under its own
weight. LSCs enable us to systematically migrate our entire codebase to
newer APIs, deprecate older APIs, change language versions, and remove
popular but dangerous practices.

The mission statement is quite clear - if we can automate LSCs, we can
rely on tooling more to make larger changes, but still cover the change
with tests. It takes less human scrutiny and duplicated feedback in code
reviews, and the change can be explained simply and replicated.

Enter Semgrep.

Semantic grep for source code allows us to find extremely complex matches
and provide replacements for the patterns we can replace. This is
especially true for code cleanups, struct renames, field renames and
other code smells. I've identified various code defects over time,
let's go over a few examples.

## Receiver constructor pattern

Constructors typically have signatures like these examples:

```go
func NewRequest(method, url string, body io.ReadCloser) (*Request, error)
func NewClient(options ClientOptions) (*Client, error)
func NewLicense(key string) *License
...
```

But, it's also possible you may have a constructor like this:

```go
type options struct {}

func (options) New() *options {
	return &options{}
}

var opts = options{}.New()
```

I've written about [value receiver
constructors](https://scene-si.org/2018/03/08/an-argument-for-value-receiver-constructors/)
and how `NewOptions()` or `options{}.New()` are compiled to the same go
assembly, but, reading the code there is a semantic difference. The
constructor is coupled to the options value twice - from the receiver,
and the return value. This constructor format is semantically harder to
understand, because the receiver is unused.

The following semgrep rule finds such constructors and renames them.

```yaml
  - id: tyk.fix.oop.constructors
    patterns:
      - pattern-either:
        - pattern: func ($K $VAR) New() *$VAR
    fix: |
      func New$VAR() *$VAR
    languages:
      - go
    message: |
      Move away from type receiver allocators.
    severity: WARNING
```

Now our `func (T) NewT() *T` became a `func NewT() *T`, and we need to
update the usage. We can find find and replace those with semgrep as
well:

```yaml
  - id: tyk.fix.oop.constructors.usage
    patterns:
      - pattern-either:
        - pattern: $T{}.New()
    fix: |
      New$T()
    languages:
      - go
    message: |
      Move away from type receiver allocators.
    severity: WARNING
```

This gives us a complete rewrite for consistency. The changes have been
smaller to review and the PR could be checked for correctness.

## Struct naming

If people don't have a well enforced naming conventions or a package
structure convention, they inevitably end up with stuttering config
options. Semgrep can be used to fix those naming issues as well. If the
struct is internal use, it's name can be corrected.

```
  - id: tyk.fix.portal.model.stutter
    patterns:
      - pattern-either:
        - pattern-regex: PortalModelPortalConfig
    fix: PortalConfig
    languages:
      - go
    message: Rename struct
    severity: WARNING
```

This model name stuttered as it had been incorrectly prefixed. It ended
up having a few replacements in code, and also uses `pattern-regex` so
references in comments are updated. Sometimes we don't need semantic
matching, we can resort to what's essentially a complicated string
replacement.

## Code duplication vs. a global anchor

A call you can avoid means less code you have to look at. Our logger has
some copy paste duplication, noted with `"prefix"` fields on the keys
being logged, somewhere in the triple digits. This ended up needing
handling for multiple prefix values and mapping those to particular
variables.

```
  - id: tyk.fix.log.:log:.remove.empty.withFields
    pattern: 'log.WithFields(logrus.Fields{"prefix": ":prefix:"})'
    fix: :log:
    languages:
      - go
    message: Removing prefix single field
    severity: WARNING

  - id: tyk.fix.log.:log:.remove.prefix.from.Fields
    pattern: 'log.WithFields(logrus.Fields{"prefix": ":prefix:",$X})'
    fix: |
      :log:.WithFields(logrus.Fields{
      	$X,
      })
    languages:
      - go
    message: Removing prefix from map
    severity: WARNING
```

This is a small template which I render with some bash script to generate
the final rules, for a set of variables. The `:prefix:` value is a
literal pattern to find, and the `:log:` is the variable to use instead
of the global `log.` invocation. This glues it together:

```bash
#!/bin/bash
set -e

# Run this script to regenerate `log.yml`

function rewriteLog() {
	local prefix=$1
	local log=$2
	sed -ze "s/:prefix:/$prefix/g;s/:log:/$log/g" log.yml.tpl
}

function rewriteLogs() {
	echo "---"
	echo "# == Special thanks to Zaid Albirawi =="
	echo
	echo "rules:"

	# For each prefixed logger with a global variable...

	rewriteLog "main" "mainLog"
	rewriteLog "certs" "certLog"
	rewriteLog "pub-sub" "pubSubLog"
	rewriteLog "dashboard" "dashLog"

	rewriteLog "api" "apiLog"
	rewriteLog "host-check-mgr" "hostCheckLog"
	rewriteLog "coprocess" "coprocessLog"
	rewriteLog "python" "pythonLog"
	rewriteLog "webhooks" "webhookLog"
}

rewriteLogs > log.yml
```

This produces a slightly larger replacement file. An example replacement
it makes looks like this:

![Example: replacement produced with Semgrep](/img/2023/refactor-code-duplication.png)

It looks like what we're doing is just having a different global
variable. That's true. Having a global `log` available in the package
scope is horrible, but first we need to move away from it, and then make
people use the `Logger()` function that is sometimes already in scope or
figure out how to inject the dependency and drop the global.

## Other

I've also looked at other tooling for large scale code changes, two stood out:

- https://pkg.go.dev/rsc.io/rf
- https://rakyll.org/eg/

I wish there was more tooling around code refactoring that we could do by
spec, and semgrep fills that void quite well today. IDE tooling like
"move function" may be an option, but may or may not work given your
couplings. As it is, just the final code change may be unrevievable due
to the volume, but the semgrep rules that produce it are reviewable.

While even code generated changes need a cursory review, the compile time
safety and test suites may cover the important parts of ensuring that a
code rewrite didn't end up breaking something. This is especially true if
you're still in the process of introducing naming conventions and better
code structure.
