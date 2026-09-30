---
name: os-tickets
description: Decompose an OpenSpec change into tracer-bullet tickets using the to-tickets methodology, output to openspec/changes/<change>/tasks.md
---

Read and follow the to-tickets skill's full ticketing process, then apply
these overrides (this file wins on conflict):

1. Output destination: openspec/changes/<change>/tasks.md (one task group
   per ticket, with blocking relationships marked as `Blocked by:`). Never
   publish to any external tracker.
2. Format must follow OpenSpec task conventions (`## N. <title>` groups,
   `- [ ] N.M <task>` checkboxes) and pass `openspec validate <change>`.
3. Also honour the `rules.tasks` entries in openspec/config.yaml. Those rules
   are injected when OpenSpec generates tasks itself, but not when this skill
   writes tasks.md, so apply them here explicitly.
4. Markdown rules: blank lines around headings, lists and code fences;
   language tags on code fences; no bold lines as pseudo-headings.
5. Write ticket content in the documentation language stated in AGENTS.md
   (default: Traditional Chinese); keep technical terms and identifiers in
   English.
