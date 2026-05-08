# Codex Starter Memory Snapshot

**Проект:** Codex Starter
**Статус:** готовится commit/push v1.2.0
**Последнее обновление:** 2026-05-08T21:55:53Z

## Что сделано

- Добавлены настройки из официального Codex Sample Config: `plan_mode_reasoning_effort`, `tool_output_token_limit`, project doc fallback, history limits, `fast_mode`, `enable_request_compression`.
- README.md и README.en.md обновлены: версия `v1.2.0`, ссылка на Sample config и уточненный раздел экономии токенов.
- Переведена конфигурация Codex на официальный `.codex/config.toml`.
- Вынесены hook-подписки в официальный `.codex/hooks.json`; legacy `.codex/settings.json` удалён.
- Добавлены advanced-настройки Codex: reasoning summary/verbosity, agents limits, shell environment policy, sandbox network policy, telemetry/privacy defaults.
- README.md и README.en.md обновлены: версия `v1.1.0`, official docs badges, описание базирования на официальной документации OpenAI Codex, рекомендации по экономии токенов.
- `init-project.sh`, `CODEx.md` и правила обновлены под новую схему `.codex/config.toml` + `.codex/hooks.json`.
- Усилен `/finish`: честные проверки, безопасный commit flow, учет `repo_access`, список подозрительных файлов.
- Согласована политика красных тестов между `autonomy.md` и `/finish`.
- Обновлен `pre-compact` hook: checkpoint только для tracked изменений после фильтрации запрещенных путей.
- Расширены `commit-policy.md`, `context-management.md` и `.gitignore` под секреты, локальные БД, storage, build/test artifacts и логи.
- Убрана маскировка ошибок из `db-migrate` и `playwright` skills.
- `framework-state-mode.sh` теперь осторожно работает как `public`, если `repo_access` отсутствует и найден публичный GitHub remote.
- Обновлены `README.md` и `README.en.md` перед публикацией.

## Проверки

- `git diff --check` — passed
- `bash -n scripts/init-project.sh scripts/framework-state-mode.sh scripts/switch-repo-access.sh .codex/hooks/*.sh` — passed
- `scripts/framework-state-mode.sh check-safe-mode` — passed
- `python3 -m json.tool .codex/hooks.json` — passed
- `codex debug prompt-input 'config smoke test'` — passed
- Тестовый раннер проекта не найден — tests skipped

## В процессе

- Сделать безопасный commit v1.2.0.
- Проверить commit и выполнить `git push origin main`.

## Следующее

- После push зафиксировать hash коммита и результат публикации в финальном отчете.
