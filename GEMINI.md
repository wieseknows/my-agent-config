# Global engineering rules

## Working style
- Before coding: read the surrounding code, find existing patterns, and reuse them. Do not invent a new pattern if one exists.
- For anything non-trivial: write a short plan first (files to touch, risks, open questions). Ask only if the answer changes the design.
- Make the smallest change that solves the ticket. No drive-by refactors; list them separately as suggestions.
- Never add a dependency without stating why existing ones don't work.
- Never silently swallow errors, disable tests, or weaken validation to get green.

## Quality bar
- Code must compile, lint clean, and pass existing tests before you report done.
- Every behavior change gets a test. Bug fix = failing test first, then fix.
- Public APIs: validate input at the boundary, return explicit errors, no magic nulls.
- Prefer composition and small single-purpose units; extract shared logic when used 2+ times, not earlier.

## Reporting
- At the end give: what changed, why, how it was verified, known risks/follow-ups.
- If you couldn't verify something, say so explicitly instead of implying it works.

## Comments and language
- All code comments, XML/JSDoc docs, commit messages, log messages, and identifiers must be in English only, even if the conversation is in Russian.
- Add short, clear comments only where they help: explain WHY (intent, trade-offs, non-obvious constraints, workarounds), not WHAT the code already says.
- Document public APIs and non-trivial algorithms/regexes/queries. Do not comment trivial code, and do not leave commented-out code or noise like "// increment i".
- Keep comments up to date: if you change the logic, update or remove the related comment.
- Reply to me in Russian; keep all code artifacts in English.