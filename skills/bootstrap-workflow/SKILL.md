---
name: bootstrap-workflow
description: Set up the OpenSpec × Matt Pocock skills hybrid workflow in the current repo — installs OpenSpec and the engineering skills, then tailors openspec/config.yaml and AGENTS.md to this project through a short interview. User-invoked.
disable-model-invocation: true
---

# Bootstrap workflow

Sets up the hybrid workflow: **OpenSpec is the artifact skeleton (the long-term "what"); Matt Pocock's engineering skills are the discipline layer (the "how")**. The fixed parts are installed by a script; the project-specific parts are decided with the user.

Talk to the user in their language (default: Traditional Chinese). Files you write follow the documentation language settled in step 3.

## 1. Pre-flight

- Confirm the working directory is the root of a git repo. If it is not a git repo, ask whether to run `git init` — don't do it silently.
- Note what already exists: `openspec/`, `AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, `docs/adr/`, `.agents/skills/`. The script never overwrites; you must **merge** into existing files, never replace them.

## 2. Install the fixed parts

Run the script that ships with this skill (it is in `scripts/` next to this file):

```bash
bash <this-skill-dir>/scripts/bootstrap.sh
```

Default agents: `claude-code,codex,pi`. Pass `--agents` if the user wants a different set. It installs OpenSpec (`openspec init`) and the Pocock skills (without `to-spec`), checks that the `to-tickets` sections referenced by the config template's `rules.tasks` still exist upstream, and copies `docs/agents/{issue-tracker,domain}.md`. If a step fails, show the error and stop; don't improvise a workaround.

## 3. Interview for the project-specific parts

First explore the repo yourself (manifest files, directory layout, README, test setup, any requirements docs). **Facts are your job; only decisions go to the user.** Then ask in rounds, grilling-style: number each question and give your recommended answer, ask every question whose prerequisites are settled in one round, wait for answers.

Settle at least these:

1. **What the project is**: one or two sentences, plus the tech stack (confirm what you found).
2. **Source of truth for requirements**: where the requirements live (a doc, a client spec, the user's head) and **who owns them**. If they belong to a client or other party, the requirement-sovereignty rule applies (step 4).
3. **What one vertical slice means here**: the thing a human can verify with one command. With a UI it is usually one user-facing feature through DB → backend → frontend; without one it is a behaviour you can check from the CLI or tests (e.g. "for config X the output matches the baseline"). Get a concrete example and its acceptance command.
4. **External APIs** the slices will cross (brokers, vendors, payment…), so the fake-adapter rule has names in it.
5. **Commands**: install, test (full and single file), lint/format, anything else a contributor must run before committing.
6. **Documentation language** for specs, tickets and docs (default Traditional Chinese, identifiers in English).
7. **Hard rules** the project already knows (invariants, "never do X", past incidents worth encoding). "None yet" is a fine answer.

## 4. Write the tailored files

- **`openspec/config.yaml`**: start from `templates/openspec-config.yaml`. Fill `context` with the project summary, stack, where requirements live, and the key invariants; replace `{{VERTICAL_SLICE_DEFINITION}}` with this project's slice definition and example; replace `{{DOC_LANGUAGE}}`. Add project-specific rules under `rules` if the interview produced any. Keep the template's `rules.proposal` grilling gate and the two `rules.tasks` entries that reference `to-tickets`: they are how ticket slicing happens inside `/opsx:propose` (there is no separate ticketing skill). If a config already exists, merge: keep its entries and add what's missing.
- **`AGENTS.md`**: a project section (language rule, what the project is, commands, hard rules; if requirements belong to someone else add the requirement-sovereignty rule — engineering decisions may be answered on the spot, business decisions become open questions with configurable behaviour, never invented) followed by the contents of `templates/AGENTS.workflow.md`. If `AGENTS.md` exists, add only the missing sections.
- **`CLAUDE.md`**: must contain `@AGENTS.md`. Create it with just that line if absent; if present, add the import line without touching the rest.
- Don't create `CONTEXT.md` or ADRs now — `/domain-modeling` creates them when terms and decisions actually settle.

## 5. Verify and report

- `openspec validate --all` (or `openspec list` when there are no changes yet) runs without error.
- Every entry in `.claude/skills/` resolves (no broken symlinks) and `skills-lock.json` lists `grilling` and `to-tickets`.
- `grep -n '{{' openspec/config.yaml` finds nothing (every template placeholder was replaced).
- Show the user a short list of what was created or merged, and the next step: start the first change with `/grill-with-docs`, then `/opsx:propose` in the same session.

Do not commit; leave that to the user.
