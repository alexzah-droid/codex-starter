# Codex Starter v1

[![Version](https://img.shields.io/badge/version-v1.0.0-2563eb)](https://github.com/alexzah-droid/codex-starter)
[![Status](https://img.shields.io/badge/status-active-16a34a)](https://github.com/alexzah-droid/codex-starter)
[![Template](https://img.shields.io/badge/template-codex--starter-7c3aed)](https://github.com/alexzah-droid/codex-starter)
[![Installer](https://img.shields.io/badge/installer-scripts%2Finit--project.sh-f59e0b)](https://github.com/alexzah-droid/codex-starter/blob/main/scripts/init-project.sh)
[![Shell](https://img.shields.io/badge/shell-bash-111827?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Git](https://img.shields.io/badge/git-required-f05032?logo=git&logoColor=white)](https://git-scm.com/)
[![Python](https://img.shields.io/badge/python3-recommended-3776ab?logo=python&logoColor=white)](https://www.python.org/)
[![Codex](https://img.shields.io/badge/Codex-rules%2Bskills%2Bagents%2Bhooks-111827?logo=openai&logoColor=white)](https://github.com/openai/codex)

`Codex Starter` — это готовая скелетная среда для проектов, в которых основной рабочий агент — Codex. Она предоставляет согласованную структуру правил, навыков, агентов, хуков и памяти, чтобы агент работал автономно и не терял контекст.

## Что входит в этот шаблон

- `manifest.md` — метаданные проекта и политика `repo_access`
- `.codex/settings.json` — стартовые настройки Codex runtime, хук-подписки и права
- `.codex/rules/` — постоянные operational правила для агента
- `.codex/skills/` — workflow-шаблоны для команд `/start`, `/finish`, `/testing` и др.
- `.codex/agents/` — роли субагентов: `researcher`, `implementer`, `reviewer`
- `.codex/hooks/` — guardrails на lifecycle-события
- `.codex/SNAPSHOT.md` — локальная память проекта
- `scripts/` — режимы управления framework state и безопасное переключение `repo_access`

## Почему этот шаблон

Codex Starter помогает:

- сохранять автономность агента
- защищать контекст проекта от потери
- разделять проектный паспорт и operational-логику
- контролировать историю git для framework state
- поддерживать единый workflow для новых и существующих проектов

## Быстрый старт

### 1. Клонируйте шаблон

```bash
git clone https://github.com/alexzah-droid/codex-starter.git
cd codex-starter
```

### 2. Установите starter в ваш проект

Если вы хотите развернуть шаблон прямо в текущем каталоге проекта:

```bash
bash scripts/init-project.sh
```

Если вы уже используете локальный checkout, можно указать шаблон явно:

```bash
bash scripts/init-project.sh --template /path/to/codex-starter
```

### 3. Настройте проект

- заполните `CODEx.md` под ваш проект
- проверьте `manifest.md`
- при необходимости создайте `.codex/settings.local.json`
- запустите `/start` в Codex

## Repo Access

`repo_access` задаёт, можно ли хранить framework state в git:

- `private-solo` — framework state может быть зафиксирован в репозитории
- `private-shared` / `public` — framework state остаётся локальным

Для публичных/shared репозиториев выполните:

```bash
scripts/switch-repo-access.sh public --commit
```

или

```bash
scripts/switch-repo-access.sh private-shared --commit
```

## Что делать после установки

1. Настройте `CODEx.md` для вашего проекта.
2. Обновите `.codex/settings.json` и, при необходимости, создайте `.codex/settings.local.json`.
3. Проверьте структуру `.codex/`, `scripts/` и `manifest.md`.
4. Запустите Codex и выполните `/start`.

## Структура

- `.codex/rules/` — operational правила, которые задают поведение агента
- `.codex/skills/` — повторно используемые сценарии работы
- `.codex/agents/` — роли субагентов
- `.codex/hooks/` — фоновые guardrails
- `.codex/SNAPSHOT.md` — локальная память состояния
- `scripts/` — управление режимами и инициализация

## Контакт

Этот репозиторий — стартовый шаблон для Codex. Для предложений и улучшений создавайте issue на GitHub.
