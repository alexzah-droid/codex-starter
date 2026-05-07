# Codex Starter v1

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

## Зачем это нужно

Основная ценность шаблона:

- автономность агента
- защита от потери контекста
- явная модель, где хранится память проекта
- стандартная структура для новых и существующих репозиториев
- отдельный режим для публичных/shared репозиториев

## Установка

Скопируйте файлы из этого шаблона в корень целевого проекта и запустите:

```bash
bash scripts/init-project.sh
```

или используйте `--template` для работы из локального checkout.

## Repo Access

`repo_access` задаёт, можно ли хранить framework state в git:

- `private-solo` — framework state может быть зафиксирован в репозитории
- `private-shared` / `public` — framework state остаётся локальным

Перед публикацией в общий репозиторий переключайтесь через `scripts/switch-repo-access.sh`.
