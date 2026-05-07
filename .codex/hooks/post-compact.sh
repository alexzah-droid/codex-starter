#!/bin/bash
# Post-Compaction Hook
# Запускается после compaction контекста.

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SNAPSHOT="$PROJECT_DIR/.codex/SNAPSHOT.md"

if [ -f "$SNAPSHOT" ]; then
    echo ""
    echo "=== Codex post-compact state ==="
    echo ""
    sed -n '1,40p' "$SNAPSHOT" 2>/dev/null || true
    echo ""
fi

if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "=== Last commits ==="
    git log --oneline -5 -- .codex/SNAPSHOT.md manifest.md 2>/dev/null || true
fi
