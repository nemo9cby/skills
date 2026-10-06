# Question craft

How to compose questions that find the learner's frontier and move it. Examples
use nanochat (a from-scratch LLM training repo) but every pattern is
repo-agnostic. Never copy an example verbatim — re-derive each question from the
code as it exists today, so it can't misstate the repo.

## The question types

Rotate types — never two of the same shape in a row. A run of "what does X do"
questions tests recall only; alternating factual probes with assumption probes,
consequence probes, and design probes forces deeper processing.

**Mechanism walk** (L1) — the workhorse opener for a fresh concept.
> "Walk me through what happens to the input tensor between entering
> `Block.forward` and leaving it — just the order of operations and what each
> one is for."

**Fine-detail probe** (L2) — point at one expression; ask why it exists. Best
targets are the lines a reader's eye slides over: a `* 0.5`, a `dim // 2`, a
`.float()`, a transpose, an `if` guard.
> "In `apply_rotary_emb`, the head dimension is split in half and recombined
> with sin/cos. Why halves — what would rotating each dim with its neighbor do
> differently?"

**What-breaks-if** (L2) — deletion as a probe. Knowing a line means knowing what
fails without it and *how*: silently wrong vs. crash vs. slow.
> "Delete the QK norm. Does training crash, diverge, or quietly get worse — and
> when would you first notice?"

**Predict-then-verify** (L2-L4) — the strongest move available, because the
ground truth is executable. Get a committed prediction, then run it together.
Wrongness becomes undeniable and memorable instead of debatable. Also the
escape hatch for claims no code line can settle: convert the debate into a run.
> "What shape is the KV cache after generating 10 tokens at batch 2? Commit,
> then we print it."

**Counterexample hunt** (L3) — probe a stated rule by asking where it fails.
> "You said 'Muon handles all the weight matrices'. Find one weight matrix here
> that Muon does NOT handle, and why."

**Reverse question** (L2-L3) — give the effect, ask for the cause.
> "Generation degrades after exactly 2048 tokens; training was fine. Which line
> is the prime suspect?"

**Design-rationale** (L3) — why this way and not a *named* alternative
("why is this good?" invites hand-waving).
> "Why two optimizers instead of AdamW everywhere — what about embedding
> matrices makes Muon a bad fit for them?"

**Transfer/prediction** (L4) — change a constraint, walk the consequences.
> "Double `depth`, touch nothing else: which derived dims change, what happens
> to the LR, does the 20:1 data budget still hold?"

**Teach-back** (any level; a strong arc-closer) — compression as proof.
> "Explain QK norm to someone who knows softmax but has never trained a model.
> Two sentences."

**Closed-book intuition** (mastery test — "numbers to leave numbers") — file
closed, structure only. If they can answer only with the file open, mastery
isn't real yet.
> "Without looking: if we doubled the vocab size, name every place in the repo
> that would care."

**Connect-across** (L3-L4; capstone material) — bind two topics.
> "The tokenizer pads the vocab to a multiple of 64. Name every downstream
> place that padding quietly matters."

## Pretesting new territory

Entering a module they've never studied, open with 1-2 questions you expect
them to miss — and say so: "wrong answers are expected here and cost nothing."
A failed attempt primes the encoding of what follows; their wrong guess becomes
the thing the real mechanism gets contrasted against.
> "Before you read engine.py: how do you think the KV cache handles batch rows
> that finish generating at different times? Guess freely."

## Confidence and hypercorrection

When an answer sounds authoritative, ask "how sure — certain / fairly sure /
guessing?" before revealing anything. High confidence + wrong is the most
correctable state a learner can be in, *if* the correction lands as a surprise:
name it ("you were certain — here's the line that says otherwise"), show or run
the disconfirming evidence, and have them restate the correction in their own
words immediately. Then queue it `[!]`. Low-confidence errors skip the
ceremony — triage and descend as usual.

## Socratic descent — decomposing a wrong attempt

When an attempt grades 1 (wrong mechanism — not a bare "I don't know", which
gets a pointer and moves on; see SKILL.md's precedence rules), don't explain
and don't repeat the question louder. First give them one shot at self-repair
by surfacing the contradiction; if that fails, descend: find the largest
sub-question they can answer, then climb back.

Example — the learner answered "every dimension gets its own rotation" to the
RoPE halves question (a wrong attempt, so we descend):

1. Self-repair chance: "If each dim rotated alone, rotation preserves length —
   what's the length of a single number?" → confusion. Descend.
2. "Forget code — to rotate a point in a 2D plane, how many numbers do you
   need?" → "two." (grade 3 — frontier found: they have the geometry)
3. Climb: "So a rotation needs a plane. A head dim of 64 gives how many
   independent planes?" → "32."
4. Climb: "Each plane gets its own frequency. Why many frequencies instead of
   one?" → learner reconstructs the multi-scale position story.
5. Resolution: one breath of ground truth with the anchor — "that's what the
   split-halves reshape implements, gpt.py `apply_rotary_emb` — read it now and
   it should feel different." The original question is already in the queue.

The descent went *outside the code* (pure geometry) to find footing, then
walked back in. Typical: the frontier is often a prerequisite concept, not a
missing fact about the repo.

## The hint ladder (and fading)

When they're stuck mid-descent, hints go one rung per attempt, each shrinking
the search space without handing over the answer:
conceptual nudge → name the file → name the function → quote the line → full
answer. Record the rung they needed; on the next similar question start one
rung less generous. Scaffolding you never remove becomes a crutch.

## Worked examples for cold areas

When a whole area is cold (mastery low, pretest bombed), pure questioning
stalls. Narrate ONE fully-worked trace aloud (e.g., one token's journey through
`Engine.generate`), then immediately pose a near-transfer question on adjacent
code. Once they're answering ~80% in that area, stop giving worked examples —
for a warmed-up learner they actively slow learning (expertise reversal).

## Transforming a re-ask

A queue item must come back different, or you're testing echo-memory:
- Different direction: asked why → re-ask as what-breaks-if.
- Different entry point: via `gpt.py` → re-enter via the training script that
  drives it.
- Different form: verbal → predict-then-verify, or a tiny exercise.
The Note column in `journal.md` records the original miss; aim the
transformation straight at it.

## Composing the capstone

A topic capstone is one L4 question (or exercise) unanswerable without most of
the topic: a full trace ("one token, entry to exit, every transform"), a
redesign ("port this attention to GQA — every line that changes"), or a debug
scenario ("loss spikes at step 4000 — three hypotheses, each tied to a line").
Pass it cold → mark the topic mastered without apology; the point is the map,
not time-on-topic.

## Smells that a question is bad

- Answerable without having read this repo (generic trivia) — anchor it.
- Multiple questions behind one question mark — split, ask the first.
- Its answer sits in your previous message — that's echo, not retrieval.
- You don't know the answer yourself — read first, or make it an honest joint
  predict-then-verify. Never bluff.
- Yes/no phrasing that lets a coin flip score — demand the mechanism.
