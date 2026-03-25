#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

install_homebrew() {
    section "Homebrew"

    if command -v brew &>/dev/null; then
        skip "Homebrew already installed"
        track_status "Homebrew" "skipped"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Determine brew path based on architecture
    local brew_shellenv=""
    if [[ -f /opt/homebrew/bin/brew ]]; then
        brew_shellenv='eval "$(/opt/homebrew/bin/brew shellenv)"'
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        brew_shellenv='eval "$(/usr/local/bin/brew shellenv)"'
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Add to shell configs
    if [[ -n "$brew_shellenv" ]]; then
        ensure_shell_configs
        append_to_shells "$brew_shellenv"
    fi

    if command -v brew &>/dev/null; then
        success "Homebrew installed"
        track_status "Homebrew" "installed"
    else
        error "Homebrew installation failed"
        track_status "Homebrew" "failed"
    fi
}

# Run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ensure_shell_configs
    install_homebrew
fi
