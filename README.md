# Agent Config for Google Antigravity

Personal, reusable configuration that makes the Antigravity agent follow the same engineering standards in every project: global rules, workspace rules, skills, subagents, and a ticket workflow (implement, review, test).

Stack focus: C# / .NET backends, Angular / TypeScript frontends, ag-Grid.

## What's inside

| Path | What it is | Applied | Installed to |
|---|---|---|---|
| `GEMINI.md` | Global rules (style, quality bar, comments in English) | Always, every prompt | `~/.gemini/GEMINI.md` |
| `rules/` | Stack rules: .NET, Angular/ag-Grid, async error handling | Per project (activation mode set in the Rules panel) | `<project>/.agents/rules/` |
| `skills/` | Focused expertise packages (`SKILL.md` per folder) | Agent picks them by `description`, or you name one in the prompt | `~/.gemini/config/skills/` |
| `agents/` | Subagents: `implementer`, `reviewer`, `test-writer` | Invoked by the workflow or via `/agents` | `~/.gemini/config/agents/` |
| `workflows/` | Slash-command procedures, e.g. `/ticket` | Only when you type the slash command | `<project>/.agents/workflows/` |
| `install.ps1` | Copies everything to the right places | Run manually | n/a |

## Quick start

Requires Windows and PowerShell.

```powershell
git clone https://github.com/wieseknows/my-agent-config.git
cd <this-repo>

# Global config only (GEMINI.md, skills, subagents)
powershell -ExecutionPolicy Bypass -File .\install.ps1

# Global config + rules/workflows into a specific project
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Project "C:\src\my-project"
```

Restart Antigravity (or open a new session) afterwards. Running sessions may not pick up changes.

The script overwrites existing files with the same name. Back up your own `GEMINI.md` first if you already have one.

## Usage

- **Rules and `GEMINI.md`** need no action. They apply automatically.
- **Skills** are chosen by the agent from their `description`. To force one, name it in the prompt: "review this using the code-review-and-quality skill".
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

## Notes

- Paths and features follow the Antigravity docs as of November 2026 and may change. If something is not picked up, check the current docs: <https://antigravity.google/docs>.
- `~/.gemini/` is shared with Gemini CLI, so global rules written here also affect it.
- Skills in `skills/` taken from public repositories keep their original licenses. List sources here:
  - `<skill-name>`: `<source URL>`

## License

MIT (or your choice). Third-party skills are under their own licenses.