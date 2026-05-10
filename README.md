# Codex Starter v1

[![Version](https://img.shields.io/badge/version-v1.2.0-2563eb)](https://github.com/alexzah-droid/codex-starter)
[![Status](https://img.shields.io/badge/status-active-16a34a)](https://github.com/alexzah-droid/codex-starter)
[![Template](https://img.shields.io/badge/template-codex--starter-7c3aed)](https://github.com/alexzah-droid/codex-starter)
[![Installer](https://img.shields.io/badge/installer-scripts%2Finit--project.sh-f59e0b)](https://github.com/alexzah-droid/codex-starter/blob/main/scripts/init-project.sh)
[![Shell](https://img.shields.io/badge/shell-bash-111827?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Git](https://img.shields.io/badge/git-required-f05032?logo=git&logoColor=white)](https://git-scm.com/)
[![Python](https://img.shields.io/badge/python3-recommended-3776ab?logo=python&logoColor=white)](https://www.python.org/)
[![Codex](https://img.shields.io/badge/Codex-rules%2Bskills%2Bagents%2Bhooks-111827?logo=openai&logoColor=white)](https://github.com/openai/codex)
[![Official Docs](https://img.shields.io/badge/OpenAI%20Codex-official%20docs-0f766e?logo=openai&logoColor=white)](https://developers.openai.com/codex)
[![Config](https://img.shields.io/badge/config-official%20TOML-0891b2)](https://developers.openai.com/codex/config-basic)

Language: Русский | [English](README.en.md)

`Codex Starter` — это готовая скелетная среда для проектов, в которых основной рабочий агент — Codex. Она предоставляет согласованную структуру правил, навыков, агентов, хуков и памяти, чтобы агент работал автономно и не терял контекст.

Если вам нужна стартовая настройка для агента Claude, рекомендуется воспользоваться репозиторием Алексея Крола: [alexeykrol/claude-code-starter](https://github.com/alexeykrol/claude-code-starter).

Проект базируется на официальной документации OpenAI Codex: конфигурация следует страницам [Config basics](https://developers.openai.com/codex/config-basic), [Advanced configuration](https://developers.openai.com/codex/config-advanced), [Config reference](https://developers.openai.com/codex/config-reference), [Sample config](https://developers.openai.com/codex/config-sample), а lifecycle hooks вынесены в формат [Codex Hooks](https://developers.openai.com/codex/hooks).

## Что входит в этот шаблон

- `manifest.md` — метаданные проекта и политика `repo_access`
- `.codex/config.toml` — проектные настройки Codex runtime, sandbox, approvals и feature flags
- `.codex/hooks.json` — официальные lifecycle hook-подписки Codex
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
- использовать официальную схему `.codex/config.toml` и `.codex/hooks.json`
- разделять проектный паспорт и operational-логику
- контролировать историю git для framework state
- не коммитить секреты, локальные БД и артефакты проверок
- честно фиксировать статус тестов и миграций без скрытых ошибок
- поддерживать единый workflow для новых и существующих проектов

## Экономия токенов

Базовый конфиг уже снижает лишний расход: `web_search = "cached"`, `model_reasoning_summary = "concise"`, `model_verbosity = "medium"`, `tool_output_token_limit = 12000` и `enable_request_compression = true` уменьшают шум без потери управляемости. Для простых задач переопределяйте effort прямо из CLI:

```bash
codex -c model_reasoning_effort='"low"' -c model_verbosity='"low"' "обнови документацию"
codex -c model_reasoning_effort='"low"' -c model_verbosity='"low"' "поправь форматирование"
```

Для сложных задач, где экономить на рассуждении рискованно:

```bash
codex -c model_reasoning_effort='"high"' "проведи архитектурный review"
codex -c model_reasoning_effort='"high"' "найди причину падения тестов"
```

Если вы работаете из CLI и хотите короткие команды, добавьте личные профили в `~/.codex/config.toml`:

```toml
[profiles.fast]
model_reasoning_effort = "low"
model_verbosity = "low"

[profiles.deep]
model_reasoning_effort = "high"
model_verbosity = "medium"
```

После этого можно запускать `codex --profile fast "..."` или `codex --profile deep "..."`. Профили Codex являются экспериментальной CLI-возможностью; в IDE extension они могут не применяться. Не включайте `web_search = "live"` по умолчанию: используйте live-поиск только когда нужны свежие данные, внешняя документация или проверка фактов.

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
- при необходимости переопределите личные параметры в `~/.codex/config.toml`
- запустите `/start` в Codex

## Рабочий цикл

1. `/start` — загрузить `.codex/SNAPSHOT.md`, проверить git-состояние и создать локальный session log.
2. Выполнить задачу автономно: читать правила, запускать проверки, делегировать субагентам при необходимости.
3. После значимых блоков работы — делать атомарные коммиты и обновлять SNAPSHOT.
4. `/finish` — запустить проверки, обновить SNAPSHOT, безопасно подготовить коммит и дать краткий отчет.

Если тесты красные, агент не выдаёт сессию за успешно завершённую. Допустим только честный checkpoint-коммит с явным описанием падения в сообщении, SNAPSHOT и отчете.

## Repo Access

`repo_access` задаёт, можно ли хранить framework state в git:

- `private-solo` — framework state может быть зафиксирован в репозитории
- `private-shared` / `public` — framework state остаётся локальным

Framework state включает `.codex/`, `CODEx.md`, `manifest.md`, `AGENTS.md` и локальную память `.codex/SNAPSHOT.md`. В public/shared режиме в git должна попадать только продуктовая часть проекта: исходный код, пользовательская документация, production-тесты, миграции и конфиги.

Для публичных/shared репозиториев выполните:

```bash
scripts/switch-repo-access.sh public --commit
```

или

```bash
scripts/switch-repo-access.sh private-shared --commit
```

Если `repo_access` не указан, режим по умолчанию — `private-solo`. При наличии публичного GitHub remote helper-скрипты работают осторожно, как в `public`, пока `manifest.md` не обновлён явно.

## Безопасность коммитов

Правила коммитов описаны в `.codex/rules/commit-policy.md`:

- агент добавляет только конкретные безопасные файлы, без `git add .` и `git add -A`
- `.env`, ключи, credentials, локальные БД, storage, зависимости, build/test artifacts и логи не коммитятся
- lifecycle hooks могут делать checkpoint только для уже tracked изменений и после фильтрации запрещённых путей
- в public/shared режиме framework-файлы остаются локальными

Перед публикацией проверьте:

```bash
git status --short
git diff --check
scripts/framework-state-mode.sh check-safe-mode
```

## Что делать после установки

1. Настройте `CODEx.md` для вашего проекта.
2. Обновите `.codex/config.toml` и, при необходимости, личные параметры в `~/.codex/config.toml`.
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
