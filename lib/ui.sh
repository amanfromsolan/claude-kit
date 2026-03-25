#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# ui.sh — Shared terminal UI components for mac-setup
# ─────────────────────────────────────────────────────────

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─────────────────────────────────────────────────────────
# Status messages
# ─────────────────────────────────────────────────────────

info() {
    echo -e "${BLUE}[ℹ]${RESET} $1"
}

success() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

error() {
    echo -e "${RED}[✗]${RESET} $1"
}

skip() {
    echo -e "${DIM}[–] $1${RESET}"
}

# ─────────────────────────────────────────────────────────
# Section header — visual divider for each tool
# ─────────────────────────────────────────────────────────

section() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━ $1 ━━━${RESET}"
}

# ─────────────────────────────────────────────────────────
# Banner — printed once at the start
# ─────────────────────────────────────────────────────────

banner() {
    echo ""
    echo -e "${BOLD}${MAGENTA}┌─────────────────────────────────────────┐${RESET}"
    echo -e "${BOLD}${MAGENTA}│         macOS Dev Environment Setup     │${RESET}"
    echo -e "${BOLD}${MAGENTA}└─────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "${DIM}  Idempotent — safe to run multiple times${RESET}"
    echo ""
}

# ─────────────────────────────────────────────────────────
# Result tracking for summary
# ─────────────────────────────────────────────────────────

declare -a SETUP_RESULTS=()

track_status() {
    local tool="$1" status="$2"
    SETUP_RESULTS+=("$tool:$status")
}

summary() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━ Summary ━━━${RESET}"
    echo ""

    for entry in "${SETUP_RESULTS[@]}"; do
        local tool="${entry%%:*}"
        local status="${entry##*:}"

        case "$status" in
            installed)
                echo -e "  ${GREEN}[✓]${RESET} ${BOLD}$tool${RESET} — installed"
                ;;
            skipped)
                echo -e "  ${DIM}[–] $tool — already installed${RESET}"
                ;;
            failed)
                echo -e "  ${RED}[✗]${RESET} ${BOLD}$tool${RESET} — failed"
                ;;
            configured)
                echo -e "  ${GREEN}[✓]${RESET} ${BOLD}$tool${RESET} — configured"
                ;;
        esac
    done

    echo ""
    echo -e "${GREEN}${BOLD}Done!${RESET} Open a new terminal for all changes to take effect."
    echo ""
}

# ─────────────────────────────────────────────────────────
# Shell config helpers
# ─────────────────────────────────────────────────────────

# Append a line to a file only if it's not already there
append_if_missing() {
    local line="$1" file="$2"
    grep -qF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# Ensure ~/.zshrc and ~/.bashrc exist
ensure_shell_configs() {
    if [[ ! -f "$HOME/.zshrc" ]]; then
        info "Creating ~/.zshrc"
        touch "$HOME/.zshrc"
    fi
    if [[ ! -f "$HOME/.bashrc" ]]; then
        info "Creating ~/.bashrc"
        touch "$HOME/.bashrc"
    fi
}

# Append a line to both shell configs
append_to_shells() {
    local line="$1"
    append_if_missing "$line" "$HOME/.zshrc"
    append_if_missing "$line" "$HOME/.bashrc"
}
