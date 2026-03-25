#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

install_nvm() {
    section "NVM + Node"

    local nvm_installed=false
    local node_installed=false

    # Check NVM
    if [[ -d "$HOME/.nvm" ]]; then
        skip "NVM already installed"
        nvm_installed=true
    else
        info "Installing NVM..."
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash

        # Add to shell configs ourselves (we suppress nvm's default with PROFILE=/dev/null)
        ensure_shell_configs
        append_to_shells 'export NVM_DIR="$HOME/.nvm"'
        append_to_shells '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
        append_to_shells '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

        if [[ -d "$HOME/.nvm" ]]; then
            success "NVM installed"
            nvm_installed=true
        else
            error "NVM installation failed"
            track_status "NVM" "failed"
            return 1
        fi
    fi

    # Source NVM for current session
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Check Node
    if command -v node &>/dev/null; then
        skip "Node already installed ($(node --version))"
        node_installed=true
    else
        info "Installing Node LTS..."
        nvm install --lts

        if command -v node &>/dev/null; then
            success "Node LTS installed ($(node --version))"
        else
            error "Node installation failed"
            track_status "NVM + Node" "failed"
            return 1
        fi
    fi

    # Track combined status
    if $nvm_installed && $node_installed; then
        # Both were already there
        track_status "NVM + Node" "skipped"
    else
        track_status "NVM + Node" "installed"
    fi
}

# Run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ensure_shell_configs
    install_nvm
fi
