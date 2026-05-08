---
name: finish
description: "Завершение рабочей сессии. Проверка состояния, запуск тестов, обновление SNAPSHOT и отчет."
allowed-tools: Read Glob Grep Bash
disable-model-invocation: true
---

# Skill: Finish Session

## Что делать

1. **Проверить состояние:**
   - прочитать `.codex/SNAPSHOT.md`
   - проверить `manifest.md` и определить `repo_access`
   - проверить текущее состояние:
     ```bash
     git status --short
     git log --oneline -5
     ```
   - дописать прогресс в текущий session log `.codex/logs/sessions/YYYY-MM-DD_HH-MM.md`
   - если session log не найден — создать новый лог с текущим timestamp и явно отметить, что `/start` log не найден

2. **Запустить тесты:**
   ```bash
   ./scripts/run-tests.sh
   ```
   или эквивалентный запуск `npm test`, `pytest`, `cargo test`, `go test` и т.д.

   Важно:
   - не скрывать stderr и exit code через `2>/dev/null || true`
   - если тестовой команды нет — записать `tests: skipped (no test command found)`
   - если тесты упали — зафиксировать exit code и первые важные ошибки в session log и SNAPSHOT

3. **Обновить SNAPSHOT.md:**
   - добавить результат тестов
   - отметить завершённые задачи
   - зафиксировать незавершённые задачи и блокеры
   - обновить статус и дату
   - если `repo_access=public` или `repo_access=private-shared`, помнить, что `.codex/SNAPSHOT.md` обычно остаётся локальным и не должен автоматически попадать в коммит

4. **Подготовить безопасный коммит, если это уместно:**
   - выполнить:
     ```bash
     git status --short
     ```
   - если изменений нет — не коммитить, сообщить `working tree clean`
   - если тесты/проверки упали — не делать чистый finish-коммит; при необходимости сохранить прогресс отдельным checkpoint-коммитом по `autonomy.md` и явно отметить красное состояние
   - если есть подозрительные или локальные файлы — не добавлять их в коммит, описать проблему и при необходимости обновить `.gitignore`
   - подозрительные файлы и директории:
     ```text
     .env
     .env.*
     *.key
     *.pem
     *.p12
     credentials.json
     secrets/
     *secret*
     .codex/settings.local.json
     CODEx.local.md
     *.db
     *.sqlite
     *.sqlite3
     *.db-shm
     *.db-wal
     storage/
     node_modules/
     __pycache__/
     .venv/
     venv/
     .next/
     dist/
     build/
     coverage/
     test-results/
     playwright-report/
     *.log
     ```
   - перед staging проверить, какие файлы можно коммитить по `.codex/rules/commit-policy.md`
   - использовать только явный список безопасных файлов:
     ```bash
     git add <safe-file-1> <safe-file-2>
     git diff --cached --stat
     git diff --cached --check
     git commit -m "<краткое описание результата сессии>"
     ```
   - сообщение коммита должно быть конкретным, например:
     ```text
     Add API workflow test harness
     Implement analysis file replacement
     Finish workflow UI and file preview
     Update finish session guardrails
     ```
   - после коммита проверить:
     ```bash
     git status --short
     git log --oneline -1
     ```

5. **Сделать краткий отчет:**
   - что сделано
   - что осталось
   - найденные проблемы
   - какие проверки прошли/упали/были пропущены
   - был ли создан коммит, и какой hash

## Чего НЕ делать

- Не публиковать детали конфиденциальных данных
- Не удалять логи и файлы без причины
- Не коммитить `.env`, локальные БД, storage binaries, build/test artifacts или зависимости
- Не использовать `git add .` или `git add -A`
- Не выдавать красные проверки за успешное завершение и не делать чистый finish-коммит при упавших проверках
- Не коммитить автоматически, если набор файлов выглядит подозрительно
- Не коммитить `.codex/`, `CODEx.md`, `manifest.md`, `AGENTS.md` в `repo_access=public` или `repo_access=private-shared`, если commit policy не разрешает это явно
- Не продолжать работу, пока не зафиксирован итог текущей сессии в SNAPSHOT и/или коммите
