#!/bin/bash
# Pre-Compaction Hook
# Вызывается автоматически перед compaction контекста.
# Коммитит tracked изменения и обновляет timestamp в SNAPSHOT.
# НЕ обновляет содержательные секции SNAPSHOT — это ответственность агента.

# НЕ используем set -e — скрипт должен выполняться до конца даже при ошибках

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SNAPSHOT="$PROJECT_DIR/.codex/SNAPSHOT.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_HELPER="$PROJECT_DIR/scripts/framework-state-mode.sh"

is_forbidden_path() {
    case "$1" in
        .env|.env.*|*.key|*.pem|*.p12|credentials.json|secrets|secrets/*|*secret*|\
        .codex/settings.local.json|CODEx.local.md|*.db|*.sqlite|*.sqlite3|*.db-shm|*.db-wal|\
        storage|storage/*|node_modules|node_modules/*|__pycache__|__pycache__/*|\
        .venv|.venv/*|venv|venv/*|.next|.next/*|dist|dist/*|dist-release|dist-release/*|\
        build|build/*|coverage|coverage/*|test-results|test-results/*|playwright-report|\
        playwright-report/*|*.log)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

changed_tracked_paths() {
    {
        git diff --name-only 2>/dev/null || true
        git diff --cached --name-only 2>/dev/null || true
    } | sort -u
}

forbidden_changed_paths() {
    changed_tracked_paths | while IFS= read -r path; do
        [ -z "$path" ] && continue
        if is_forbidden_path "$path"; then
            printf '%s\n' "$path"
        fi
    done
}

stage_safe_tracked_paths() {
    git diff --name-only 2>/dev/null | while IFS= read -r path; do
        [ -z "$path" ] && continue
        if ! is_forbidden_path "$path"; then
            git add -- "$path" 2>/dev/null || true
        fi
    done
}

# Guard: если не git-репо — просто выйти, нечего сохранять через git
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "pre-compact: not a git repo, skipping"
    exit 0
fi

# Shared/public mode is only safe when framework files are already untracked.
# If they are still tracked, stop and surface the blocker instead of creating
# more framework-history commits on the main branch.
if [ -x "$STATE_HELPER" ]; then
    if ! "$STATE_HELPER" check-safe-mode; then
        echo "pre-compact: framework-state mode is unsafe, skipping auto-commit"
        exit 0
    fi
fi

# 1. Коммит изменений в уже отслеживаемых файлах после фильтрации.
#    Untracked файлы НЕ добавляются автоматически — это осознанное решение:
#    слепой staging может захватить секреты, артефакты сборки и т.д.
#    Агент должен добавлять новые файлы осознанно в рабочем процессе.
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    FORBIDDEN="$(forbidden_changed_paths)"
    if [ -n "$FORBIDDEN" ]; then
        echo "pre-compact: forbidden tracked paths changed, skipping auto-commit:"
        echo "$FORBIDDEN"
    else
        stage_safe_tracked_paths
        if ! git diff --cached --quiet 2>/dev/null; then
            git diff --cached --check >/dev/null 2>&1 && \
                git -c user.name="Codex" -c user.email="codex@local" \
                    commit -m "auto: pre-compaction save ($TIMESTAMP)" 2>/dev/null || true
        fi
    fi
fi

# 2. Обновить timestamp в SNAPSHOT (файл всегда обновляется локально)
if [ -f "$SNAPSHOT" ]; then
    sed -i.bak "s/\*\*Последнее обновление:\*\*.*/\*\*Последнее обновление:\*\* $TIMESTAMP (pre-compaction)/" "$SNAPSHOT" 2>/dev/null || true
    rm -f "$SNAPSHOT.bak"

    if [ -x "$STATE_HELPER" ] && [ "$($STATE_HELPER should-commit-framework-state)" = "false" ]; then
        echo "pre-compact: SNAPSHOT kept local due repo_access=$($STATE_HELPER repo-access)"
    else
        git add -- "$SNAPSHOT" 2>/dev/null || true
        git -c user.name="Codex" -c user.email="codex@local" \
            commit -m "auto: update SNAPSHOT before compaction" 2>/dev/null || true
    fi
fi

echo "pre-compact: state saved at $TIMESTAMP"
