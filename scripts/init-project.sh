#!/bin/bash
#
# Codex Starter — Bootstrap Payload
#
# Internal bootstrap used by the public root launcher.
# Разворачивает управляющую среду Codex в новом проекте.
# Не трогает существующий код. Создаёт только инфраструктуру управления.
#
# Использование:
#   bash init-project.sh                          # Интерактивный режим
#   bash init-project.sh --name "My Project"      # С именем проекта
#   bash init-project.sh --template /path/to/template  # Из шаблона
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/.."
PROJECT_DIR="$(pwd)"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error()   { echo -e "${RED}✗${NC} $1"; }

# === Parse Arguments ===
PROJECT_NAME=""
TEMPLATE_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)     PROJECT_NAME="$2"; shift 2 ;;
        --template) TEMPLATE_PATH="$2"; shift 2 ;;
        *)          shift ;;
    esac
done

# === Determine Template Source ===
if [ -n "$TEMPLATE_PATH" ] && [ -d "$TEMPLATE_PATH" ]; then
    TEMPLATE_DIR="$TEMPLATE_PATH"
elif [ -d "$SCRIPT_DIR/../.codex/rules" ]; then
    TEMPLATE_DIR="$SCRIPT_DIR/.."
else
    log_error "Template not found. Provide --template path or run from a framework checkout with scripts/"
    exit 1
fi

# === Interactive: Project Name ===
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename "$PROJECT_DIR")
    echo ""
    echo -e "${BLUE}Codex Starter — Bootstrap${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read -p "Project name [$PROJECT_NAME]: " input_name
    PROJECT_NAME="${input_name:-$PROJECT_NAME}"
fi

echo ""
log_info "Setting up environment for: $PROJECT_NAME"
echo ""

# === Create Directory Structure ===
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_success "Created: $1"
    else
        log_warning "Exists:  $1"
    fi
}

create_dir ".codex"
create_dir ".codex/rules"
create_dir ".codex/skills/start"
create_dir ".codex/skills/finish"
create_dir ".codex/skills/testing"
create_dir ".codex/skills/playwright"
create_dir ".codex/skills/db-migrate"
create_dir ".codex/skills/housekeeping"
create_dir ".codex/agents/researcher"
create_dir ".codex/agents/implementer"
create_dir ".codex/agents/reviewer"
create_dir ".codex/hooks"
create_dir ".codex/logs/sessions"
create_dir ".codex/logs/migrations"
create_dir ".codex/logs/errors"
create_dir "scripts"

# === Copy Template Files (only if not exists) ===
copy_if_missing() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$dst" ]; then
        if [ -f "$src" ]; then
            cp "$src" "$dst"
            log_success "Created: $dst"
        fi
    else
        log_warning "Exists:  $dst (not overwritten)"
    fi
}

# Rules
for rule in autonomy delegation context-management production-safety local-first commit-policy logging; do
    copy_if_missing "$TEMPLATE_DIR/.codex/rules/${rule}.md" ".codex/rules/${rule}.md"
done

# Skills
for skill in start finish testing playwright db-migrate housekeeping; do
    copy_if_missing "$TEMPLATE_DIR/.codex/skills/${skill}/SKILL.md" ".codex/skills/${skill}/SKILL.md"
done

# Agents
for agent in researcher implementer reviewer; do
    copy_if_missing "$TEMPLATE_DIR/.codex/agents/${agent}/${agent}.md" ".codex/agents/${agent}/${agent}.md"
done

# Hooks
copy_if_missing "$TEMPLATE_DIR/.codex/hooks/pre-compact.sh" ".codex/hooks/pre-compact.sh"
copy_if_missing "$TEMPLATE_DIR/.codex/hooks/post-compact.sh" ".codex/hooks/post-compact.sh"
copy_if_missing "$TEMPLATE_DIR/.codex/hooks/post-tool-checkpoint.sh" ".codex/hooks/post-tool-checkpoint.sh"
copy_if_missing "$TEMPLATE_DIR/.codex/hooks/subagent-done.sh" ".codex/hooks/subagent-done.sh"
chmod +x .codex/hooks/*.sh 2>/dev/null || true

# Local scripts installed into the target project
copy_if_missing "$TEMPLATE_DIR/scripts/framework-state-mode.sh" "scripts/framework-state-mode.sh"
copy_if_missing "$TEMPLATE_DIR/scripts/switch-repo-access.sh" "scripts/switch-repo-access.sh"
chmod +x scripts/*.sh 2>/dev/null || true

# Codex config
copy_if_missing "$TEMPLATE_DIR/.codex/config.toml" ".codex/config.toml"
copy_if_missing "$TEMPLATE_DIR/.codex/hooks.json" ".codex/hooks.json"

if [ -f ".codex/settings.json" ]; then
    log_warning "Exists:  .codex/settings.json (legacy; prefer .codex/config.toml and .codex/hooks.json)"
fi

# SNAPSHOT
if [ ! -f ".codex/SNAPSHOT.md" ]; then
    awk -v val="$TIMESTAMP" '{gsub(/\{\{DATE\}\}/, val); print}' "$TEMPLATE_DIR/.codex/SNAPSHOT.md" > ".codex/SNAPSHOT.md"
    log_success "Created: .codex/SNAPSHOT.md"
else
    log_warning "Exists:  .codex/SNAPSHOT.md (not overwritten)"
fi

# manifest.md — generate with project name
if [ ! -f "manifest.md" ]; then
    awk -v val="$PROJECT_NAME" 'BEGIN{gsub(/&/, "\\&", val)} {gsub(/\{\{PROJECT_NAME\}\}/, val); print}' "$TEMPLATE_DIR/manifest.md" > "manifest.md"
    log_success "Created: manifest.md"
else
    log_warning "Exists:  manifest.md (not overwritten)"
fi

# CODEx.md — generate with project name
if [ ! -f "CODEx.md" ]; then
    awk -v val="$PROJECT_NAME" 'BEGIN{gsub(/&/, "\\&", val)} {gsub(/\{\{PROJECT_NAME\}\}/, val); print}' "$TEMPLATE_DIR/CODEx.md" > "CODEx.md"
    log_success "Created: CODEx.md (customize this file for your project)"
else
    log_warning "Exists:  CODEx.md (not overwritten)"
fi

# .gitignore — merge, don't overwrite
if [ ! -f ".gitignore" ]; then
    cp "$TEMPLATE_DIR/.gitignore" ".gitignore"
    log_success "Created: .gitignore"
else
    added=0
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [[ "$line" == \#* ]] && continue
        if ! grep -qF "$line" ".gitignore" 2>/dev/null; then
            echo "$line" >> ".gitignore"
            added=$((added + 1))
        fi
    done < "$TEMPLATE_DIR/.gitignore"
    if [ "$added" -gt 0 ]; then
        log_success "Updated: .gitignore (+$added entries)"
    else
        log_warning "Exists:  .gitignore (up to date)"
    fi
fi

# === Git Init ===
if [ ! -d ".git" ]; then
    git init -q
    log_success "Initialized git repository"
fi

# === Summary ===
 echo ""
 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
 echo -e "${GREEN}Codex Starter ready: $PROJECT_NAME${NC}"
 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
