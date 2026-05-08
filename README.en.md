# Codex Starter v1

[![Version](https://img.shields.io/badge/version-v1.0.0-2563eb)](https://github.com/alexzah-droid/codex-starter)
[![Status](https://img.shields.io/badge/status-active-16a34a)](https://github.com/alexzah-droid/codex-starter)
[![Template](https://img.shields.io/badge/template-codex--starter-7c3aed)](https://github.com/alexzah-droid/codex-starter)
[![Installer](https://img.shields.io/badge/installer-scripts%2Finit--project.sh-f59e0b)](https://github.com/alexzah-droid/codex-starter/blob/main/scripts/init-project.sh)
[![Shell](https://img.shields.io/badge/shell-bash-111827?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Git](https://img.shields.io/badge/git-required-f05032?logo=git&logoColor=white)](https://git-scm.com/)
[![Python](https://img.shields.io/badge/python3-recommended-3776ab?logo=python&logoColor=white)](https://www.python.org/)
[![Codex](https://img.shields.io/badge/Codex-rules%2Bskills%2Bagents%2Bhooks-111827?logo=openai&logoColor=white)](https://github.com/openai/codex)

Language: [Русский](README.md) | English

`Codex Starter` is a ready-to-use skeleton environment for projects where Codex is the primary working agent. It provides a consistent structure for rules, skills, agents, hooks, and project memory so the agent can work autonomously without losing context.

## What This Template Includes

- `manifest.md` - project metadata and the `repo_access` policy
- `.codex/settings.json` - starter Codex runtime settings, hook subscriptions, and permissions
- `.codex/rules/` - persistent operational rules for the agent
- `.codex/skills/` - workflow templates for `/start`, `/finish`, `/testing`, and more
- `.codex/agents/` - subagent roles: `researcher`, `implementer`, `reviewer`
- `.codex/hooks/` - guardrails for lifecycle events
- `.codex/SNAPSHOT.md` - local project memory
- `scripts/` - framework state modes and safe `repo_access` switching

## Why Use This Template

Codex Starter helps you:

- preserve agent autonomy
- protect project context from being lost
- separate the project passport from operational logic
- control git history for framework state
- avoid committing secrets, local databases, and test artifacts
- record test and migration status honestly without hidden failures
- keep one workflow for new and existing projects

## Quick Start

### 1. Clone the template

```bash
git clone https://github.com/alexzah-droid/codex-starter.git
cd codex-starter
```

### 2. Install the starter into your project

If you want to install the template directly into the current project directory:

```bash
bash scripts/init-project.sh
```

If you are using a local checkout, you can pass the template path explicitly:

```bash
bash scripts/init-project.sh --template /path/to/codex-starter
```

### 3. Configure the project

- fill in `CODEx.md` for your project
- review `manifest.md`
- create `.codex/settings.local.json` if needed
- run `/start` in Codex

## Working Cycle

1. `/start` - load `.codex/SNAPSHOT.md`, inspect git state, and create a local session log.
2. Work autonomously: read rules, run checks, and delegate to subagents when useful.
3. After meaningful work blocks, make atomic commits and update SNAPSHOT.
4. `/finish` - run checks, update SNAPSHOT, prepare a safe commit, and report the result.

If tests are red, the agent must not present the session as cleanly finished. A checkpoint commit is allowed only when it honestly records the failure in the commit message, SNAPSHOT, and final report.

## Repo Access

`repo_access` controls whether framework state can be stored in git:

- `private-solo` - framework state may be committed to the repository
- `private-shared` / `public` - framework state stays local

Framework state includes `.codex/`, `CODEx.md`, `manifest.md`, `AGENTS.md`, and local memory in `.codex/SNAPSHOT.md`. In public/shared mode, git should contain only the product surface: source code, user-facing documentation, production tests, migrations, and project configs.

For public or shared repositories, run:

```bash
scripts/switch-repo-access.sh public --commit
```

or:

```bash
scripts/switch-repo-access.sh private-shared --commit
```

If `repo_access` is missing, the default mode is `private-solo`. When a public GitHub remote is detected, helper scripts behave conservatively as `public` until `manifest.md` is updated explicitly.

## Commit Safety

Commit rules live in `.codex/rules/commit-policy.md`:

- the agent stages only explicit safe files, never `git add .` or `git add -A`
- `.env`, keys, credentials, local databases, storage, dependencies, build/test artifacts, and logs are never committed
- lifecycle hooks may checkpoint only already tracked changes and only after filtering forbidden paths
- in public/shared mode, framework files stay local

Before publishing, check:

```bash
git status --short
git diff --check
scripts/framework-state-mode.sh check-safe-mode
```

## What To Do After Installation

1. Configure `CODEx.md` for your project.
2. Update `.codex/settings.json` and create `.codex/settings.local.json` if needed.
3. Check the `.codex/`, `scripts/`, and `manifest.md` structure.
4. Start Codex and run `/start`.

## Structure

- `.codex/rules/` - operational rules that define the agent's behavior
- `.codex/skills/` - reusable work scenarios
- `.codex/agents/` - subagent roles
- `.codex/hooks/` - background guardrails
- `.codex/SNAPSHOT.md` - local state memory
- `scripts/` - initialization and mode management

## Contact

This repository is a starter template for Codex. For suggestions and improvements, open an issue on GitHub.
