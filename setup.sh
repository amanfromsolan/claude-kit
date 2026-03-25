#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# setup.sh — macOS Dev Environment Setup
#
# Usage:
#   curl -fsSL aman.computer/install-claudekit.sh | bash
#   — or —
#   git clone https://github.com/amanfromsolan/claude-kit.git && cd claude-kit && ./setup.sh
# ─────────────────────────────────────────────────────────

REPO_URL="https://github.com/amanfromsolan/claude-kit.git"

# ─────────────────────────────────────────────────────────
# Determine if we're running from the repo or via curl pipe
# ─────────────────────────────────────────────────────────

setup_project_dir() {
    # If this script is in a dir that has lib/ui.sh, we're in the repo
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || script_dir=""

    if [[ -n "$script_dir" && -f "$script_dir/lib/ui.sh" ]]; then
        PROJECT_DIR="$script_dir"
        return
    fi

    # Running via curl pipe — clone to temp dir
    PROJECT_DIR="$(mktemp -d)"
    CLEANUP_TEMP=true

    echo "Downloading setup files..."
    if command -v git &>/dev/null; then
        git clone --depth 1 "$REPO_URL" "$PROJECT_DIR"
    else
        # No git yet (fresh machine) — try downloading as tarball
        curl -fsSL "${REPO_URL%.git}/archive/refs/heads/main.tar.gz" | tar -xz -C "$PROJECT_DIR" --strip-components=1
    fi
}

cleanup() {
    if [[ "${CLEANUP_TEMP:-false}" == "true" && -n "${PROJECT_DIR:-}" ]]; then
        rm -rf "$PROJECT_DIR"
    fi
}
trap cleanup EXIT

# ─────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────

main() {
    setup_project_dir

    # If stdin is a pipe (curl | bash), reattach to real terminal
    # so interactive prompts (Homebrew sudo, Git config) still work
    if [[ ! -t 0 ]]; then
        { exec < /dev/tty; } 2>/dev/null || true
    fi

    # Source shared UI
    source "$PROJECT_DIR/lib/ui.sh"

    # Source all installers
    source "$PROJECT_DIR/installers/xcode-cli.sh"
    source "$PROJECT_DIR/installers/homebrew.sh"
    source "$PROJECT_DIR/installers/ghostty.sh"
    source "$PROJECT_DIR/installers/bun.sh"
    source "$PROJECT_DIR/installers/nvm.sh"
    source "$PROJECT_DIR/installers/claude-code.sh"
    source "$PROJECT_DIR/installers/git-config.sh"

    banner

    # Ensure shell configs exist before any installer tries to write to them
    ensure_shell_configs

    # Run installers in dependency order
    # Xcode CLI + Homebrew are foundational — bail if they fail
    install_xcode_cli || { error "Cannot continue without Xcode CLI Tools"; summary; return 1; }
    install_homebrew || { error "Cannot continue without Homebrew"; summary; return 1; }

    # The rest are independent — one failure shouldn't block others
    install_ghostty || true
    install_bun || true
    install_nvm || true
    install_claude_code || true
    configure_git || true

    # Show what happened
    summary
}

main "$@"
