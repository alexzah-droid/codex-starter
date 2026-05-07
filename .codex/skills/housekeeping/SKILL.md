---
name: housekeeping
description: "Обслуживание проекта: документация, .gitignore, структура, drift."
allowed-tools: Read Glob Grep Bash
disable-model-invocation: true
---

# Skill: Housekeeping

## Что делать

1. **Проверить документацию:**
   - `README.md`
   - `manifest.md`
   - `CODEx.md` или `CLAUDE.md`

2. **Проверить `.gitignore`:**
   - содержит ли локальные и артефактные файлы
   - включён ли блок framework-public-ignore, если нужно

3. **Проверить структуру проекта:**
   - наличие `.codex/` и `scripts/`
   - актуальность `manifest.md`
   - наличие `AGENTS.md` и `SNAPSHOT.md`

4. **Сообщить о drift:**
   - если есть устаревшие файлы
   - если правила не соответствуют текущему процессу

## Чего НЕ делать

- Не менять рабочий код без запроса
- Не удалять файлы проекта без проверки
- Не коммитить housekeeping-исправления без описательного сообщения
