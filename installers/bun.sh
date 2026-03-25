#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

install_bun() {
    section "Bun"

    if command -v bun &>/dev/null; then
        skip "Bun already installed ($(bun --version))"
        track_status "Bun" "skipped"
        return 0
    fi

    info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash

    # Add to shell configs
    ensure_shell_configs
    append_to_shells 'export BUN_INSTALL="$HOME/.bun"'
    append_to_shells 'export PATH="$BUN_INSTALL/bin:$PATH"'

    # Source for current session
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    if command -v bun &>/dev/null; then
        success "Bun installed ($(bun --version))"
        track_status "Bun" "installed"
    else
        error "Bun installation failed"
        track_status "Bun" "failed"
    fi
}

# Run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ensure_shell_configs
    install_bun
fi
