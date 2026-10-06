# The annotated {subject}

*What each line does and what breaks if you move it.*

{1–2 paragraphs: why this path is fragile; note that most mistakes are silent. One sentence
of scope exclusions.}

## The complete {path}

You don't need to understand it all yet — just get a feel for the structure.

```{lang}
{complete code, verbatim, un-annotated}
```

## TL;DR — where the order really matters

None of these raise an exception. This table is the crib sheet:

| Line | Wrong position | What breaks |
|---|---|---|
| `{line}` | {After/Before/Inside `{other line}`} | {Mechanism + symptom, ≤ 2 sentences.} |
| Omit `{line}` | — | {What silently degrades.} |

Now let's go through each of these in detail.

## {Operation 1 heading — its role, not its syntax}

**[1]** — {Capsule: 2–3 sentences. What it does. What state it touches. What it does NOT do.}

```{lang}
{minimal excerpt}                      # [1]
```

{Mechanism paragraph(s): one level below the API surface, naming concrete state.}

{Wrong-vs-correct pair, if this step has a common misplacement:}

```{lang}
# wrong — {consequence}
{code}

# correct
{code}
```

{**`parameter`** glossary paragraphs — when it matters, when it doesn't.}

<details><summary>◎ think — {Socratic question}</summary>

{Answer.}

</details>

{Repeat one section per operation, in execution order.}

## {Optional: the production/optimized variant}

{Same path, hardened/tuned. Explain each delta from the basic version.}

```{lang}
{optimized code}
```

## The complete annotated {path}

The same {path}, with every line referenced.

{**1** — one-line capsule (≤ 20 words).}
{**2** — …}

```{lang}
# ── {section} ──────────────────────────────
{full code, every significant line tagged}   # [1]
```
