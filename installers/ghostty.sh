#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

install_ghostty() {
    section "Ghostty"

    if [[ -d "/Applications/Ghostty.app" ]]; then
        skip "Ghostty already installed"
        track_status "Ghostty" "skipped"
        return 0
    fi

    # Need brew for this one
    if ! command -v brew &>/dev/null; then
        error "Homebrew is required to install Ghostty — run homebrew.sh first"
        track_status "Ghostty" "failed"
        return 1
    fi

    info "Installing Ghostty..."
    brew install --cask ghostty

    if [[ -d "/Applications/Ghostty.app" ]]; then
        success "Ghostty installed"
        track_status "Ghostty" "installed"
    else
        error "Ghostty installation failed"
        track_status "Ghostty" "failed"
    fi
}

# Run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_ghostty
fi
