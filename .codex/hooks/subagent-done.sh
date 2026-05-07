#!/bin/bash
# Subagent done hook
# Напоминает о цикле коммит + SNAPSHOT после завершения субагента.

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SNAPSHOT="$PROJECT_DIR/.codex/SNAPSHOT.md"

echo ""
echo "⚡ Subagent finished. Не забудьте:"
echo "  1) оценить результат"
echo "  2) git add + git commit"
echo "  3) обновить .codex/SNAPSHOT.md"
echo ""

if [ -f "$SNAPSHOT" ]; then
    echo "Текущее состояние SNAPSHOT:"
    grep -n "##" "$SNAPSHOT" 2>/dev/null | head -20 || true
    echo ""
fi
