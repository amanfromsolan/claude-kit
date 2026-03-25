#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

configure_git() {
    section "Git Config"

    local name email
    local needed=false

    name="$(git config --global user.name 2>/dev/null || true)"
    email="$(git config --global user.email 2>/dev/null || true)"

    if [[ -n "$name" && -n "$email" ]]; then
        skip "Git already configured ($name <$email>)"
        track_status "Git Config" "skipped"
        return 0
    fi

    # Can't prompt if stdin isn't a terminal (e.g. curl pipe)
    if [[ ! -t 0 ]]; then
        warn "Git user.name/email not set — run this interactively to configure"
        warn "  ./installers/git-config.sh"
        track_status "Git Config" "skipped"
        return 0
    fi

    if [[ -z "$name" ]]; then
        echo ""
        read -rp "$(echo -e "${BLUE}[ℹ]${RESET} Enter your Git name: ")" name
        git config --global user.name "$name"
        needed=true
    fi

    if [[ -z "$email" ]]; then
        read -rp "$(echo -e "${BLUE}[ℹ]${RESET} Enter your Git email: ")" email
        git config --global user.email "$email"
        needed=true
    fi

    if $needed; then
        success "Git configured ($name <$email>)"
        track_status "Git Config" "configured"
    else
        skip "Git already configured"
        track_status "Git Config" "skipped"
    fi
}

# Run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_git
fi
