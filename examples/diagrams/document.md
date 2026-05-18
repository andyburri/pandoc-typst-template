---
listings: true
date: 2026-01-22
---

# PlantUML

This text should link to @plantuml-test.

```plantuml {caption="PlantUML Test" align=left #plantuml-test}
@startuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: another authentication Response
@enduml

```

# Mermaid

```{.mermaid caption="Mermaid Test" align=left}
---
title: Simple sample
---
stateDiagram-v2
    [*] --> Still
    Still --> [*]

    Still --> Moving
    Moving --> Still
    Moving --> Crash
    Crash --> [*]

```
