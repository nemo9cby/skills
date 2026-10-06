# Style Guide: the annotated-walkthrough format

Reverse-engineered from "The annotated PyTorch training loop" (idlemachines.co.uk), itself in
the lineage of "The Annotated Transformer". Follow this anatomy; exemplar excerpts are quoted
verbatim throughout.

## Contents

1. [Title and framing](#1-title-and-framing)
2. [Section anatomy: the layered recipe](#2-section-anatomy-the-layered-recipe)
3. [The failure table](#3-the-failure-table)
4. [Commentary layers in detail](#4-commentary-layers-in-detail)
5. [Voice rules](#5-voice-rules)
6. [The closing annotated script](#6-the-closing-annotated-script)
7. [Adapting beyond ML code](#7-adapting-beyond-ml-code)

## 1. Title and framing

- Title: **"The annotated {subject}"**. Subtitle: **"What each line does and what breaks if
  you move it."** Adapt the subtitle only if ordering genuinely isn't the fragility axis
  (then name the real one: "…and what breaks if you skip it / reorder it / retry it").
- Intro paragraph names the *feel* of the fragility, not a feature list:

  > "Building a PyTorch training loop is fairly straightforward, but getting everything in
  > the right place and in the right order can feel surprisingly fragile. There are loads of
  > moving parts and after the most basic errors are fixed, most of the other mistakes can
  > be pretty hard to spot."

- State scope exclusions in one sentence ("Distributed training, FSDP, and multi-GPU setups
  are out of scope here").
- First content section shows the complete code with an explicit permission not to
  understand it yet:

  > "Let's look, first of all, at the complete training loop. You don't need to understand
  > or memorise it yet, just get a feel for the structure."

## 2. Section anatomy: the layered recipe

One section per operation, **in execution order**, heading = the operation's role, not its
syntax ("The weight update", not "optimiser.step()"). Each section layers, in order:

1. **Step number** matching the `[N]` markers.
2. **Capsule** — 2–3 mechanical sentences stating: what it does, what state it touches, and
   (crucially) what it does NOT do. Exemplars:

   > "Traverses the computation graph from the scalar loss back to every leaf parameter.
   > Populates `.grad` on each parameter via the chain rule. **Does not modify weights.**"

   > "Reads `.grad` on every parameter and applies the update rule. Moment estimates are
   > updated. **Weights change here and only here.**"

3. **Minimal excerpt** — just the line(s) for this step, with surrounding context lines
   elided to `...`, and the marker as a comment: `optimiser.step()  # [7]`.
4. **Deep commentary** — the layers from section 4 below, as many as the operation earns.
   A trivial step gets a capsule and two paragraphs; the load-bearing step gets math,
   variants, and history.

## 3. The failure table

Placed immediately after the complete code, before any section. Three columns:

| Line | Wrong position | What breaks |
|---|---|---|
| `optimiser.zero_grad()` | After `loss.backward()` | Gradients from multiple batches accumulate. Update uses their sum, not the current batch alone. |
| `scheduler.step()` | Inside batch loop | LR decays `len(loader)` times per epoch instead of once. |
| Omit `model.train()` after `model.eval()` | — | Dropout disabled, BatchNorm frozen. The model trains in eval mode **without error**. |

Rules:

- **Silent failures only, or mostly.** The table's framing sentence is the point:
  > "The reason to memorise these is that none of them will raise an exception."
  Loud failures (immediate exceptions) can be mentioned inline in sections but don't earn
  table rows.
- Include **omission rows** ("Omit X — …") with a dash in the position column.
- "What breaks" states the **mechanism and the symptom**, in ≤ 2 sentences, at the level of
  named state: not "training degrades" but "the optimiser holds references to the discarded
  originals and applies updates to them instead."
- 5–10 rows. Fewer means the subject may not deserve this format; more means split the essay.

## 4. Commentary layers in detail

Deploy per section, only where earned:

- **Mechanism ("what actually happens")** — go one level below the API surface, naming the
  concrete objects and attributes involved:

  > "For a device-only move, `nn.Module.to()` modifies each parameter's `.data` attribute
  > in-place and the optimiser's references remain correct. When a dtype conversion is
  > combined (e.g. `.half().to(device)`), `nn.Module.to()` allocates new `nn.Parameter`
  > objects and replaces them in the module's internal registry; the optimiser, constructed
  > before this, retains references to the originals and applies updates to them instead."

- **Wrong-vs-correct code pair** — for the most common misplacement, show both, labeled with
  comments stating the consequence, not just "wrong":

  ```python
  # wrong — lr decays len(loader) times per epoch instead of once
  for X_batch, y_batch in loader:
      optimiser.step()
      scheduler.step()

  # correct
  for X_batch, y_batch in loader:
      optimiser.step()
  scheduler.step()
  ```

- **Parameter/variant glossary** — bolded inline terms, one paragraph each, always including
  *when it matters* and *when it doesn't*: "**`pin_memory=True`** … It only helps when
  `num_workers > 0` and you're transferring to CUDA."
- **Quantified claims** — numbers over adjectives: "roughly halve memory usage",
  "10–30% faster", "For Adam on a 7B-parameter model … roughly 56GB of optimiser state."
  Only state numbers that are sourced or measured.
- **Math** — only where the formula is the explanation (an update rule, a numerical-stability
  trick), typeset properly, followed by a plain-English gloss of the trick.
- **History/practice context** — where a default comes from: "max_norm=1.0 is used in the
  original GPT-2 paper, most subsequent language model work…"
- **Version notes** — inline, parenthetical: "(Only available in PyTorch 2.0+)", "the older
  `torch.cuda.amp` import still works but is deprecated."
- **Think-questions** — Socratic prompts with hidden answers, placed right after the concept
  they test: "◎ think — Why must the model be moved to the device before constructing the
  optimiser?" Render as `<details><summary>` blocks in markdown. 3–8 per essay.
- **Note asides** — short boxed digressions (blockquote with a **note** label) for adjacent
  concepts that would derail the main flow (e.g. what an `nn.Parameter` actually holds).
- **Misconception callouts** — name them as such: "Calling `model(x)` invokes `__call__`,
  not `forward` directly. This is a classic misconception for new users."

## 5. Voice rules

- Second person, present tense, imperative where instructing. Contractions fine.
- **Every claim at the level of named state.** The test: could a reader set a debugger
  watchpoint on the thing you named? "`.grad` is empty. The call is a no-op." passes;
  "the gradients aren't ready yet" fails.
- **State the non-effects.** The most clarifying sentences in the format say what does NOT
  happen: "Does not modify weights." / "No other standard layers are affected."
- Never hedge mechanism ("probably", "should", "I think"). If unsure, read more source until
  sure, or drop the claim.
- Sentences short. One mechanism per paragraph. Bold is for glossary terms being defined,
  not for emphasis.

## 6. The closing annotated script

The final section re-prints the **entire** path with every significant line tagged
`# [N]` (N runs across the whole script, e.g. [1]–[19]), preceded by a legend: a numbered
list of one-line capsules, each ≤ 20 words, each a compression of its section's capsule:

> **14** — `backward()`: reverse-mode AD. Populates `.grad` on every leaf parameter. Weights unchanged.
> **16** — `optimiser.step()`: reads `.grad`, applies Adam update, updates moment estimates. Weights change.

Use section-divider comments inside the code (`# ── data ──…`, `# ── training loop ──…`).
The legend + code must stand alone as a review sheet.

## 7. Adapting beyond ML code

The format transfers to any order-sensitive sequence; translate the axes:

| Original axis | General equivalent |
|---|---|
| epoch/batch loop | the unit of iteration (request, message, frame, transaction) |
| `.grad` accumulation | any accumulating/shared mutable state (buffers, caches, counters, connection state) |
| train/eval mode flags | any modal state (feature flags, transaction isolation, locks held) |
| OOM from graph retention | any silent resource leak (handles, listeners, goroutines, sessions) |
| GPU-efficiency section | the "production hardening" variant (timeouts, retries, pooling, batching) |
| practice problems | optional "exercises for the reader" (implement the primitive from scratch) |

If the subject has no meaningful ordering constraints — pure functions, declarative config —
this format is wrong; write ordinary reference docs instead.
