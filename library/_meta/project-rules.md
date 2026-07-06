---
type: reference
audience: claude
updated: 2026-07-06
tags: [efficiency, workflow]
summary: "workflow-specific operating rules — build gates, shared libs, MCP servers, deploy. Pairs with the general claude-efficiency rules."
---

# workflow project rules

The project-specific half of [[claude-efficiency]] (general, lives in
`~/ai-workflow`, symlinked here). Everything below is about *this* project.
Fill sections as facts are learned; delete ones that never apply.

## Environment
- MCP servers: (none yet)
- Hooks currently live: (none yet)
- Cheap vault scan: `grep -rh "^summary:" "/home/jonasz/workflow/library" --include=*.md`.

## Reuse before writing (shared libs)
- (list the project's shared helpers here — duplicated logic is the main bloat source)

## Verification
- Quick check: (typecheck command)
- Real gate: (build/test command + gotchas)

## Deploy & git
- Vault repo: Claude commits, never pushes. Code repo: commits stay the user's
  unless asked.
- (deploy runbook pointers)
