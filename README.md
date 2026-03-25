# claude-kit

Modular, idempotent macOS dev environment setup. Run it on a fresh MacBook or re-run it anytime — it only installs what's missing.

## What it installs

| Tool | Method |
|------|--------|
| Xcode Command Line Tools | `xcode-select --install` |
| Homebrew | Official installer |
| Ghostty | `brew install --cask ghostty` |
| Bun | Official installer |
| NVM + Node LTS | Official nvm script |
| Claude Code | Official installer |
| Git config | Interactive name/email prompt |

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/amanfromsolan/claude-kit/main/setup.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/amanfromsolan/claude-kit.git
cd claude-kit
./setup.sh
```

## Install a single tool

Each installer works standalone:

```bash
./installers/bun.sh
./installers/nvm.sh
./installers/ghostty.sh
./installers/claude-code.sh
./installers/homebrew.sh
./installers/xcode-cli.sh
./installers/git-config.sh
```

## Project structure

```
claude-kit/
├── setup.sh              # Entry point — orchestrates everything
├── lib/
│   └── ui.sh             # Shared terminal UI (colors, status, helpers)
└── installers/
    ├── xcode-cli.sh
    ├── homebrew.sh
    ├── ghostty.sh
    ├── bun.sh
    ├── nvm.sh
    ├── claude-code.sh
    └── git-config.sh
```

## How it works

- **Checks before installing** — each tool is detected before any install runs
- **Creates `~/.zshrc` and `~/.bashrc`** if they don't exist
- **Appends PATH/init lines** idempotently — no duplicates on re-run
- **Prints a summary** at the end showing what was installed vs skipped

## License

MIT
