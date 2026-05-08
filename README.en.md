# Codex Starter v1

[![Version](https://img.shields.io/badge/version-v1.1.0-2563eb)](https://github.com/alexzah-droid/codex-starter)
[![Status](https://img.shields.io/badge/status-active-16a34a)](https://github.com/alexzah-droid/codex-starter)
[![Template](https://img.shields.io/badge/template-codex--starter-7c3aed)](https://github.com/alexzah-droid/codex-starter)
[![Installer](https://img.shields.io/badge/installer-scripts%2Finit--project.sh-f59e0b)](https://github.com/alexzah-droid/codex-starter/blob/main/scripts/init-project.sh)
[![Shell](https://img.shields.io/badge/shell-bash-111827?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Git](https://img.shields.io/badge/git-required-f05032?logo=git&logoColor=white)](https://git-scm.com/)
[![Python](https://img.shields.io/badge/python3-recommended-3776ab?logo=python&logoColor=white)](https://www.python.org/)
[![Codex](https://img.shields.io/badge/Codex-rules%2Bskills%2Bagents%2Bhooks-111827?logo=openai&logoColor=white)](https://github.com/openai/codex)
[![Official Docs](https://img.shields.io/badge/OpenAI%20Codex-official%20docs-0f766e?logo=openai&logoColor=white)](https://developers.openai.com/codex)
[![Config](https://img.shields.io/badge/config-official%20TOML-0891b2)](https://developers.openai.com/codex/config-basic)

Language: [Русский](README.md) | English

`Codex Starter` is a ready-to-use skeleton environment for projects where Codex is the primary working agent. It provides a consistent structure for rules, skills, agents, hooks, and project memory so the agent can work autonomously without losing context.

This project is based on the official OpenAI Codex documentation: configuration follows [Config basics](https://developers.openai.com/codex/config-basic), [Advanced configuration](https://developers.openai.com/codex/config-advanced), [Config reference](https://developers.openai.com/codex/config-reference), and lifecycle hooks use the documented [Codex Hooks](https://developers.openai.com/codex/hooks) format.

## What This Template Includes

- `manifest.md` - project metadata and the `repo_access` policy
- `.codex/config.toml` - project Codex runtime settings, sandbox, approvals, and feature flags
- `.codex/hooks.json` - official Codex lifecycle hook subscriptions
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
- use the official `.codex/config.toml` and `.codex/hooks.json` schema
- separate the project passport from operational logic
- control git history for framework state
- avoid committing secrets, local databases, and test artifacts
- record test and migration status honestly without hidden failures
- keep one workflow for new and existing projects

## Token Savings

The default config already avoids some waste: `web_search = "cached"`, `model_reasoning_summary = "concise"`, and `model_verbosity = "medium"` keep output controlled without removing useful context. For simple tasks, override effort directly from the CLI:

```bash
codex -c model_reasoning_effort='"low"' -c model_verbosity='"low"' "update the documentation"
codex -c model_reasoning_effort='"low"' -c model_verbosity='"low"' "fix formatting"
```

For complex tasks where shallow reasoning is risky:

```bash
codex -c model_reasoning_effort='"high"' "run an architecture review"
codex -c model_reasoning_effort='"high"' "find why tests are failing"
```

If you work from the CLI and want shorter commands, add personal profiles to `~/.codex/config.toml`:

```toml
[profiles.fast]
model_reasoning_effort = "low"
model_verbosity = "low"

[profiles.deep]
model_reasoning_effort = "high"
model_verbosity = "medium"
```

Then run `codex --profile fast "..."` or `codex --profile deep "..."`. Codex profiles are an experimental CLI feature; they may not apply in the IDE extension. Do not enable `web_search = "live"` by default: use live search only when you need fresh data, external documentation, or fact checking.

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
- override personal settings in `~/.codex/config.toml` if needed
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
2. Update `.codex/config.toml` and, if needed, personal settings in `~/.codex/config.toml`.
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
