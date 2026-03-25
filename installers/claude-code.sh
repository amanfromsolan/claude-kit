#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

install_claude_code() {
    section "Claude Code"

    if command -v claude &>/dev/null; then
        skip "Claude Code already installed"
        track_status "Claude Code" "skipped"
        return 0
    fi

    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash

    # Source updated PATH if the installer modified shell configs
    if [[ -f "$HOME/.local/bin/claude" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if command -v claude &>/dev/null; then
        success "Claude Code installed"
        track_status "Claude Code" "installed"
    else
        error "Claude Code installation failed"
        track_status "Claude Code" "failed"
    fi
}

# Run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_code
fi
