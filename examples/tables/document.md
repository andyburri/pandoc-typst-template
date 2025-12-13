# Outline

`#outline(target: figure.where(kind: table))`{=typst}

```markdown
`#outline(target: figure.where(kind: table))`{=typst}
```

# Tables Example

| Column One     |    Column Two    |                                                                        Column Three |
| :------------- | :--------------: | ----------------------------------------------------------------------------------: |
| Row One Left   |  Row One Center  | Row One Right, which should automatically break if it reaches the width of the page |
| Row Two Left   |  Row Two Center  |                                                                       Row Two Right |
| Row Three Left | Row Three Center |                                                                     Row Three Right |

: Tables Caption

# Striped Table `{typst:fill=striped}`

| Column One     |    Column Two    |    Column Three |
| :------------- | :--------------: | --------------: |
| Row One Left   |  Row One Center  |   Row One Right |
| Row Two Left   |  Row Two Center  |   Row Two Right |
| Row Three Left | Row Three Center | Row Three Right |
| Row Four Left  | Row Four Center  |  Row Four Right |

: Striped Table {typst:fill=striped}

# Table aligned left `{align=left}`

| Column One   |   Column Two   |  Column Three |
| :----------- | :------------: | ------------: |
| Row One Left | Row One Center | Row One Right |
| Row Two Left | Row Two Center | Row Two Right |

: Left Table {align=left}

# Table right aligned `{align=right .unlisted}`

| Column One   |   Column Two   |  Column Three |
| :----------- | :------------: | ------------: |
| Row One Left | Row One Center | Row One Right |
| Row Two Left | Row Two Center | Row Two Right |

: Unlisted Table {align=right .unlisted}

# Plain Table

|           |           |           |
| :-------- | --------- | --------- |
| Row One   | Row One   | Row One   |
| Row Two   | Row Two   | Row Two   |
| Row Three | Row Three | Row Three |

: Plain Table {.plain}

# Table with custom column widths `{columns="(25%, 30%, 1fr)"}`

| Column One                                  | Column Two                                | Column Three    |
| :------------------------------------------ | :---------------------------------------- | :-------------- |
| Row One Left with some Fachverantwortlicher | Row One Center                            | Row One Right   |
| Row Two Left                                | Row Two Center                            | Row Two Right   |
| Row Three Left                              | Row Three Center<br>Row Three after break | Row Three Right |

: Tables Caption {columns="(25%, 30%, 1fr)"}
