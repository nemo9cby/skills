# skills

My personal, reusable agent skills. One repo, every machine: Windows, WSL, Linux, macOS.

Each skill is a folder under `skills/` with a `SKILL.md` (frontmatter `name` + `description`, then the instructions) and optional `references/`, `assets/`, `scripts/`. This is the [Agent Skills](https://agentskills.io) layout, so the same folder works in Claude Code, Codex and anything that speaks it.

## Skills

| Skill | What it does |
|---|---|
| [annotated-walkthrough](./skills/annotated-walkthrough/SKILL.md) | Write an idlemachines-style annotated walkthrough of one critical code path: full code first, a failure-ordering table, then line-by-line dissection. |
| [learn](./skills/learn/SKILL.md) | Deep learning coach for any topic: Waitzkin's Art of Learning plus Karpathy's from-scratch method, in phases from diagnosis and fundamentals to hands-on struggle and refinement. |

## Install

**Dev-mode (what I do on my own machines).** Clone once, symlink into every harness, `git pull` to update:

```bash
git clone git@github.com:nemo9cby/skills.git ~/Projects/skills
~/Projects/skills/scripts/link-skills.sh                    # -> ~/.claude/skills and ~/.agents/skills
~/Projects/skills/scripts/link-skills.sh ~/.codex/skills    # any other dir
```

On Windows run it from Git Bash. The script asks for native links (`MSYS=winsymlinks:native`) and warns if it had to fall back to a copy.

**Claude Code plugin.** Managed, read-only bundle:

```
/plugin marketplace add nemo9cby/skills
/plugin install nemo-skills@nemo9cby
```

**Any agent via skills.sh.** Copies editable files into a project:

```bash
npx skills@latest add nemo9cby/skills
```

## Adding a skill

1. `mkdir skills/<name>` and write `skills/<name>/SKILL.md`. Keep the body short and move long material into `references/`.
2. Add the path to `skills` in `.claude-plugin/plugin.json` and a row to the table above.
3. Re-run `scripts/link-skills.sh` on machines that use dev-mode.

## License

MIT
