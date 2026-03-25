#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

install_xcode_cli() {
    section "Xcode Command Line Tools"

    if xcode-select -p &>/dev/null; then
        skip "Xcode CLI Tools already installed"
        track_status "Xcode CLI Tools" "skipped"
        return 0
    fi

    info "Installing Xcode Command Line Tools..."
    info "A system dialog may appear — click 'Install' to proceed"

    # Trigger the install dialog
    xcode-select --install 2>/dev/null || true

    # Wait for installation to complete (timeout after 10 minutes)
    info "Waiting for installation to finish..."
    local waited=0
    until xcode-select -p &>/dev/null; do
        if (( waited >= 600 )); then
            error "Timed out waiting for Xcode CLI Tools (10 min)"
            track_status "Xcode CLI Tools" "failed"
            return 1
        fi
        sleep 5
        (( waited += 5 ))
    done

    if xcode-select -p &>/dev/null; then
        success "Xcode CLI Tools installed"
        track_status "Xcode CLI Tools" "installed"
    else
        error "Xcode CLI Tools installation failed"
        track_status "Xcode CLI Tools" "failed"
    fi
}

# Run standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_xcode_cli
fi
