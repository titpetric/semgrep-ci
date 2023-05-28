---
title: "Modify after write"
date: 2023-05-27T21:30:59+02:00
lastmod: 2023-05-27T21:30:59+02:00
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

A "modify after write" error refers to a situation where a program or
process attempts to modify data after it has been written or committed to
a particular location or state. In Go terms, this can mean that a field
may be modified after the struct has been written to the database.

When debugging a login issue, we found a field was not updated in the
database. On investigation, I found that a field in the user data was
being modified after it had been saved to the database. Fixing it was
just reordering a few lines of code.

The following semgrep rule matches for the problematic pattern, and found other
occurences of it in the codebase:

```yaml
rules:
  - id: tyk.find.modify-after-write
    patterns:
      - pattern-either:
        - pattern: |
            $T.Update()
            ...
            $T.$K = $V
    languages:
      - go
    message: |
      Current database models trigger a write to
      the database with the Update() function. It
      is a code smell if the data model is updated
      immediately afterwards. It hints that some
      field was modified for write in a wrong place.
    severity: WARNING
```

The underlying issue here is the coupling of storage logic directly to
the data model with a function receiver. The `Update` func will write out
the function receiver into the database and return a `bool`.

The real solution is to separate the data model from the storage. A
repository interface can provide a deterministic signature for populating
the data model. There are additional defects to address when implementing
the repository interface:

- Take a context value, it is required for tracing/telemetry hooks,
- Return errors, a `false` can be HTTP 404 or HTTP 503, errors can be handled,
- Follow `Update(context.Context, *T) error` or `(*T, error)` signature,
- Provide a `NewT() *T` constructor to control data model allocations.

Having the data model be filled with a receiver like in our example is a
code smell. While that may be fine for code that uses `encoding/json` and
even for database clients like sqlx, all that unsafe code that uses
reflection now lives behind the interface, rather than being engrained
everywhere.

The benefits of having a well defined repository interface:

- the data model becomes reusable,
- testing scope becomes small and focused,
- you have control of allocations in small scope,
- operations become a single repository call,
- enable new functionality, instrumentation...

Locality of behaviour lets us reason better about how data is being
stored. Repository interfaces let us reason better about how data should
be encoded into the database, as well as give us an introspection point
for OpenTelemetry.