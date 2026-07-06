---
project: workflow
type: reference
audience: both
updated: 2026-07-05
tags: [dotfiles, design, decision]
summary: "Why dotfiles moved off the bare-repo pattern + the tool landscape (stow/dotbot/chezmoi/yadm/nix) if plain symlinks ever stop being enough."
---

# Dotfiles approach — rationale + tool landscape

The decision itself lives in [[_moc]] (key decisions: plain directory +
`install.sh` symlinks). This note keeps the fuller *why* and the alternatives
surveyed, for whenever the setup outgrows plain symlinks.

## Why off the bare-repo pattern

The old setup was `git --git-dir=$HOME/.cfg --work-tree=$HOME`. Two structural
problems, beyond taste:

- **Nothing is scoped.** The "repo" is effectively the whole home directory —
  every git operation (and every AI/tooling pass) sees `$HOME`, so neither
  humans nor agents can reason about what's actually managed. A self-contained
  `dotfiles/` dir makes the managed set explicit and lets an agent work *inside
  the repo* and log everything it does.
- **Bootstrap is fiddly.** Reproducing on a new machine means the checkout
  dance + sparse ignore tricks; a plain repo is `clone` + `install.sh`.

## Tool landscape (if plain symlinks stop being enough)

Surveyed 2026-07-05, before choosing the plain-dir approach:

- **GNU Stow** — simple symlink farm manager; directory-folding model (see
  [[dir-symlink-tracking]] for adopting that idea *inside* install.sh).
- **Dotbot** — YAML-configured symlinker; minimal, easy for scripts/AI to edit.
- **chezmoi** — templating for per-machine differences, built-in secrets
  handling; the most popular modern option, most machinery to learn.
- **yadm** — bare-repo style but with a managed-files list; fixes the scoping
  problem without symlinks.
- **Nix / home-manager** — fully declarative and reproducible; steepest curve.

Chosen: none of them yet — plain dir + `install.sh`, lowest lock-in, with an
easy later move to Dotbot/chezmoi if templating or secrets handling become real
needs.

## Provenance

Recovered at 3rd gardening (2026-07-05) from a forked Claude memory: the
planning session ran in pre-rename `~/workspace`, whose per-project memory dir
wasn't wired into `~/ai-workflow/memories`, so this rationale never reached the vault.
