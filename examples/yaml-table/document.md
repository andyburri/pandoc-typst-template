---
date: 2026-05-17
title: YAML Tables
---

# YAML-driven tables

Tables loaded from YAML via `#yaml-table` (see `template/yamltable.typ`).

## Key–value (`kv`)

Flat dictionary, no header row by default.

`#yaml-table("tables/kv.yaml")`{=typst}

## Key–value striped (`kv`)

Flat dictionary, no header row by default.

`#yaml-table("tables/kv.yaml", fill: "striped")`{=typst}

## Map (`map`)

Column definitions and row records.

`#yaml-table("tables/map.yaml")`{=typst}

## Grid (`grid`)

Map schema with per-column align and width.

`#yaml-table("tables/grid.yaml")`{=typst}

## Matrix (`matrix`)

Headers plus rows as arrays.

`#yaml-table("tables/matrix.yaml")`{=typst}

## Records (`records`)

Top-level list of homogeneous records.

`#yaml-table("tables/records.yaml")`{=typst}

## Header omitted (`map`)

`#yaml-table("tables/map.yaml", header: false)`{=typst}

## Striped fill (`matrix`)

`#yaml-table("tables/matrix.yaml", fill: "striped")`{=typst}

## Figure with caption (`grid`)

```{=typst}
#yaml-table-figure("tables/grid.yaml", caption: [Parts inventory])
<tbl:yaml-grid>
```
