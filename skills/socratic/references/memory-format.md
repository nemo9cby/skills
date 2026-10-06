# Memory file formats

Both files live in the target repo at `.claude/socratic/`. They are read at every
session start and belong to the learner as much as to you: plain markdown,
scannable in ten seconds. Dates are absolute (YYYY-MM-DD).

> Example content below is from nanochat and is illustrative only — derive every
> topic, concept, and anchor from the actual target repo. Never copy the taxonomy.

Recency conventions differ by design — keep them straight: **evidence cells
append newest LAST** (reads like a history), **the session log inserts newest
FIRST** (reads like a status board).

## `map.md` — syllabus fused with learner state

One file answers both "what is there to know here" and "where does the learner
stand". Statuses live inline so a syllabus refresh can never clobber learner
state: refreshes edit rows in place and never touch Status/Evidence cells.

```markdown
# Socratic map — nanochat
_Built at commit bc51da8 · scope: full repo · sessions completed: 3_
_Profile: knows transformer architecture broadly; fine details are the
bottleneck — open topics at L1, expect the frontier at L2. Observed: confuses
train-time vs inference-time paths._

## Topic: Architecture — `nanochat/gpt.py`
_Capstone: not attempted. Why this topic matters: every later stage (training,
inference) is a different way of driving this one forward pass._

| Concept | Key anchor | Status | Evidence |
|---|---|---|---|
| RMSNorm (no learnable params) | gpt.py `norm()` | known | 2026-07-20: explained why F.rms_norm w/o weight; 2026-07-22: held on re-ask |
| Rotary embeddings | gpt.py `apply_rotary_emb` | shaky | 2026-07-22: knew rotation idea, missed why only half the head dims pair up |
| QK norm | gpt.py `CausalSelfAttention` | new | |
```

Conventions:
- **Header**: commit hash (drives the refresh offer), scope (`full repo` or the
  mapped subtree), `sessions completed` — a derived convenience mirror of the
  journal log, updated at session end; **the journal log is the authority** if
  they ever disagree. The Profile line is read every session and sets question
  entry levels; append observed tendencies to it as they emerge.
- **Status ladder**: `new` → `shaky` → `known` (grade-3 at L2+ once) →
  `mastered` (grade-3 at L2+ in two different sessions, one on a transformed
  re-ask, at least one file-closed). Downgrades are normal: a failed review
  moves `known` → `shaky`. A first-probe miss (`new` → `shaky`) counts as
  miss-caused: write it through immediately.
- **Evidence**: dated one-liners, newest last, keep ~2 per concept (drop the
  oldest). Write what they did, not a grade: "explained X", "missed Y". This is
  what lets a fresh session pick up the thread instantly.
- **Concept granularity**: one askable idea (~one arc of questions), not a file.
  "Rotary embeddings" is a concept; "gpt.py" is not.

## `journal.md` — queue, exercises, session log

```markdown
# Socratic journal — nanochat
_gitignore: offered 2026-07-18 — accepted_

## Review queue
| Item | Concept | Box | Due | Missed | Note |
|---|---|---|---|---|---|
| Why only half the head dims rotate in RoPE | Rotary embeddings | 1 | #3 | 2026-07-22 ×1 | said "all dims rotate" |
| [!] Muon orthogonalizes the UPDATE, not the weights | Muon | 2 | #4 | 2026-07-20 ×2 | confidently inverted it |

## Exercises (max 2 open)
| Exercise | Concept | Assigned | Done means | Status |
|---|---|---|---|---|
| Implement apply_rotary_emb from memory in a scratch file; diff against gpt.py | Rotary embeddings | 2026-07-22 | matches on a random (B,T,H,D) tensor | open |

## Session log
- **#3 · 2026-07-22 · architecture**: RMSNorm firmed. RoPE half-dims queued.
  Assigned RoPE exercise. Next: QK norm, then attention.
- **#2 · 2026-07-20 · training**: ...
```

Conventions:
- **Session number**: n = newest log entry number + 1, determined at session
  start. Write the stub `- **#n · <date> · (in progress)**` on the session's
  FIRST write to either file (replace "(in progress)" with the real entry at
  session end). A crashed session therefore still counts, and no queue row can
  reference a session number that doesn't exist.
- **Box | Due**: Due is absolute, computed at write time — box 1 → `#n` (this
  session, re-ask after ≥4 intervening questions), box 2 → `#n+1`, box 3 →
  `#n+3`. **Due whenever Due ≤ current session number** — this absorbs skipped
  sessions and box-1 leftovers from sessions that ended early. Promotion on a
  grade ≥2 re-ask rewrites Box and Due; the box-3 retiring pass requires a
  grade 3. Any miss → back to box 1, bump ×count. Retiring deletes the row and
  records the win in `map.md` evidence.
- **`[!]`** marks confident-wrong items: serve them first among due items, and
  they reappear next session regardless of box.
- **The Note records the miss, never the answer.** The queue is read aloud in
  dashboards and re-asks; a note containing the ground truth spoils the cold
  re-probe it exists to schedule.
- **Session log**: 2-3 lines each, newest first, ending with a `Next:` clause —
  "continue" resumes exactly that clause. Keep the 10 most recent entries;
  delete older ones (durable state lives in map.md).
- **Exercises**: "Done means" is a concrete, checkable condition. Not attempted
  next session → no pressure, move on; untouched 3+ sessions → offer once to
  drop or replace.

## `bank.md` (optional) — question ammunition

If present (e.g., pre-built by a deep mapping pass), it holds per-concept fine
details and sample questions with `file:line` + ground-truth anchors. Treat it
as ammunition, not gospel: re-verify every anchor against the current code
before asking from it, and never read the whole file into context — pull the
section for the topic at hand.

## First-run creation

Create the directory and both files in the same turn the map is built.
`journal.md` starts with empty tables and the `#1` stub. Offer once to add
`.claude/socratic/` to `.gitignore` (knowledge state is personal; committing it
to a shared repo would be odd) and record the outcome in the journal header
line — later sessions check that line instead of re-asking.
