---
name: annotated-walkthrough
description: Write an "annotated code walkthrough" essay for a critical code path, in the style of idlemachines' "The annotated PyTorch training loop" — show the complete code first, build a failure-ordering table (Line | Wrong position | What breaks), then dissect each operation in execution order with mechanism-level commentary, and end with the fully line-tagged code plus a numbered legend. Use when asked to "annotate this code", "write an annotated walkthrough/guide", "explain what each line does and what breaks if you move it", "document the training loop / request lifecycle / startup sequence line by line", or "apply the idlemachines / annotated-transformer style" to a codebase.
---

# Annotated Code Walkthrough

Produce a deep-dive essay about ONE critical code path, where the annotation is driven by
**ordering constraints and silent failure modes**, not line-by-line paraphrase. The title
formula is the thesis: *"The annotated X — what each line does and what breaks if you move it."*

Read [references/style-guide.md](references/style-guide.md) before writing — it contains the
full section anatomy, commentary-layer recipe, voice rules, and exemplar excerpts from the
original essay. Copy [assets/template.md](assets/template.md) as the output skeleton.

## Workflow

### 1. Scope: pick the critical path

This format works on a **sequence whose order matters**, not a whole codebase. Good subjects:
a training loop, a request lifecycle, a startup/shutdown sequence, a transaction commit path,
a render pipeline, a message-consumer loop. 15–60 lines of load-bearing code is the sweet spot.

If the user names a codebase but not a path, find the entry point, identify 2–3 candidate
sequences, and ask which one (or pick the most fragile one and say why). Everything else in
the codebase is out of scope — say so explicitly in the intro, as the original does
("Distributed training … is out of scope here").

### 2. Analyze: the move test

Read the entire path plus every function it calls, until each line's effect on shared state
is understood. Then run the **move test** on every line — this analysis is the essay's spine:

- What happens if this line moves **earlier**? **Later**? Is **deleted**? Runs **twice**?
- Which lines does it have a hidden ordering dependency on, and through **what shared state**
  (an attribute, a buffer, a flag, a connection, a cache)?
- Does misplacement **raise an error, or fail silently**? Silent failures are the priority —
  the original's table exists because "none of them will raise an exception."

Record findings as tuples: `(line, wrong position, mechanism of breakage, symptom)`.
Claims must come from reading the actual code (and its dependencies' docs/source), never from
plausibility. If the code is runnable, verify the top 2–3 breakage claims by actually
introducing the misplacement and observing the symptom; report which claims were verified.

### 3. Write: the bookend structure

Assemble the essay in this fixed order (details and exemplars in the style guide):

1. **Intro** — why this path is fragile; mistakes are silent; scope disclaimer.
2. **The complete code** — un-annotated, verbatim. "You don't need to understand it yet,
   just get a feel for the structure."
3. **TL;DR failure table** — `Line | Wrong position | What breaks`, from the move-test
   tuples. Include omission rows ("Omit X — …"). This table IS the essay's thesis.
4. **One section per operation, in execution order.** Each section follows the layered
   recipe in the style guide: numbered capsule → minimal excerpt with `# [N]` marker →
   mechanism → ordering rationale → wrong-vs-correct pair → parameter glossary →
   quantified notes → optional think-question.
5. **Optional: the optimized/production variant** — same loop, tuned, each delta explained.
6. **The complete annotated script** — full code again, every line tagged `# [N]`, preceded
   by a numbered legend of one-line capsules. A reader who reads only the legend + code
   should still get 80% of the value.

### 4. Verify and deliver

- Cross-check every `[N]` tag: markers in the final code, the legend, and section numbers
  must agree. Miscounted tags are the most common defect in this format.
- Re-read the failure table against the sections: every table row must have a section that
  explains its mechanism.
- Deliver as a markdown file named `annotated-<subject>.md` next to the code it documents
  (or where the user asks). Offer to publish as an artifact for sharing.
