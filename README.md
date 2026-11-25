# Agent Config for Google Antigravity

Personal, reusable configuration that makes the Antigravity agent follow the same engineering standards in every project: global rules, workspace rules, skills, subagents, and a ticket workflow (implement, review, test).

Stack focus: C# / .NET backends, Angular / TypeScript frontends, ag-Grid, Bash / dotfiles.

## What's inside

| Path | What it is | Applied | Installed to |
|---|---|---|---|
| `GEMINI.md` | Global rules (style, quality bar, comments in English) | Always, every prompt | `~/.gemini/GEMINI.md` |
| `rules/` | Stack rules: .NET, Angular/ag-Grid, async error handling, Bash/dotfiles | Per project (activation mode set in the Rules panel) | `<project>/.agents/rules/` |
| `skills/` | Focused expertise packages (`SKILL.md` per folder) | Agent picks them by `description`, or you name one in the prompt | `~/.gemini/config/skills/` |
| `agents/` | Subagents: `implementer`, `reviewer`, `test-writer` | Invoked by the workflow or via `/agents` | `~/.gemini/config/agents/` |
| `workflows/` | Slash-command procedures, e.g. `/ticket` | Only when you type the slash command | `<project>/.agents/workflows/` |
| `install.sh` | Primary cross-platform installer (Git Bash + Linux) | Standalone or invoked by `dotfiles` | n/a |
| `install.ps1` | Thin PowerShell wrapper over `install.sh` (Windows) | Manual Windows run | n/a |
| `tests/smoke_test.sh` | Isolated `HOME` smoke tests for `install.sh` | CI / manual verification | n/a |

## Quick start

### Git Bash (Windows) or Linux (recommended)

```bash
git clone https://github.com/wieseknows/my-agent-config.git
cd my-agent-config

# Global config only (GEMINI.md, skills, subagents)
./install.sh --global

# Global config + project rules/workflows (repeatable --project)
./install.sh --global --project /c/dev/projects/my-app --project /c/dev/projects/api
```

### PowerShell (Windows wrapper)

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Global
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Global -Project "C:\dev\projects\my-app"
```

### Integration with `dotfiles`

If you use [wieseknows/dotfiles](https://github.com/wieseknows/dotfiles), you do not need to clone or run this repository manually. Configure `INSTALL_AGENT_CONFIG=true` and `AGENT_CONFIG_PROJECTS` in `~/.bashrc.local` (see `.bashrc.local.template` in `dotfiles`), and `dotfiles/install.sh` will clone/pull `my-agent-config` and invoke `./install.sh` automatically.

Restart Antigravity (or open a new session) afterwards. Running sessions may not pick up changes.

## Installer behavior & CLI contract

`./install.sh` supports:
- `--global`: install `GEMINI.md`, `skills/`, and `agents/` into `~/.gemini/`.
- `--project <path>`: install `rules/` and `workflows/` into `<path>/.agents/` (can be passed multiple times). If `<path>` is a Git repository, `.agents/` is added to `<path>/.git/info/exclude` if not already present.
- `--dry-run`: print planned actions without modifying files.
- `--backup-dir <path>`: store timestamped backups under `<path>/<timestamp>/...` instead of `<target>.bak.<timestamp>`.
- `--force`: copy files even when content hashes match.
- `-h, --help`: show usage.

The installer is idempotent: files are copied (not symlinked) only when their SHA-256 hash differs from the destination, and differing destination files are backed up with a timestamp before overwriting.

## Usage

- **Rules and `GEMINI.md`** need no action. They apply automatically.
- **Skills** are chosen by the agent from their `description`. To force one, name it in the prompt: `"review this using the code-review-and-quality skill"`.
- **Ticket pipeline:** type `/ticket` and paste the ticket text. The workflow plans, implements, reviews (max 2 fix iterations), writes tests, runs build/tests, and reports.
- **Subagents** can be inspected and monitored with `/agents`.

## Conventions

- All code, comments, docs, commit messages, and log messages are in English.
- Comments explain *why*, not *what*.
- Bug fix = failing test first, then fix.
- Smallest change that solves the task; refactors are suggested separately.

## Customizing

1. Repeated the same correction to the agent more than once? Add one line to the relevant file in `rules/` or `GEMINI.md`.
2. Keep `GEMINI.md` short; it is injected into every prompt. Each rule file has a 12,000 character limit.
3. Keep skills focused and descriptions specific. Many skills with similar descriptions make the agent choose worse.
4. Review third-party skills before use. They are instructions (and sometimes scripts) the agent will execute.

## Troubleshooting

- **Windows symlinks:** Creating symlinks in Windows Git Bash requires Developer Mode or elevated privileges and can fail silently. `install.sh` always copies files and uses content hashes to stay idempotent.
- **PowerShell execution policy:** If `.\install.ps1` is blocked, run it with `powershell -ExecutionPolicy Bypass -File .\install.ps1` or run `./install.sh` directly in Git Bash.
- **Shared `~/.gemini/` with Gemini CLI:** `~/.gemini/` is shared with Gemini CLI, so global rules written to `~/.gemini/GEMINI.md` also affect Gemini CLI sessions. Backups are created automatically before overwriting any existing `GEMINI.md`.

## Notes

- Paths and features follow the Antigravity docs as of November 2026 and may change. If something is not picked up, check the current docs: <https://antigravity.google/docs>.

## License

MIT
