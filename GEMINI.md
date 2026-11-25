# Global engineering rules

## Language
- Reply to me in Russian.
- All code artifacts must be in English only: identifiers, comments, XML/JSDoc, commit messages, log messages.

## Working style
- Before coding, read the surrounding code, call sites, configuration, and relevant tests. Reuse existing patterns; do not invent new ones.
- Never assume how code works from names alone. If intended behavior can't be established from the codebase, ask before changing it.
- For non-trivial tasks, write a short plan first (files to touch, risks, open questions). Ask only if the answer changes the design.
- Make the smallest change that solves the task. No drive-by refactors, reformatting, or renames of unrelated symbols; list such ideas separately as suggestions.
- Never silently swallow errors, disable tests, or weaken validation to get green.
- Preserve original file encoding and BOM (especially UTF-8 with BOM, EF BB BF). Edit tools may strip it: after modifying a file, check git diff or header bytes and restore the BOM. New files follow the neighboring files' convention.

## Quality bar
- Code must compile, lint clean, and pass existing tests before you report done.
- Every behavior change gets a test. Bug fix = failing test first, then the fix.
- Public APIs: validate input at the boundary, return explicit errors, no magic nulls.
- Prefer composition and small single-purpose units. Extract shared logic when the duplication is meaningful (generally 2+ real uses), not earlier.
- Remove unused code, imports, and variables introduced by your changes. No commented-out code, no TODO/FIXME unless requested or documenting a known follow-up.
- Prefer descriptive names over abbreviations. Use guard clauses instead of deep nesting. Don't use regions to hide poor structure.

## Comments
- Comment only to explain WHY (intent, trade-offs, non-obvious constraints, workarounds), not WHAT.
- Document public APIs and non-trivial algorithms, regexes, and queries.
- Keep comments in sync with the code: update or remove them when logic changes.

## Architecture and dependencies
- Respect existing architecture and layer boundaries. Keep business logic out of controllers, UI components, infrastructure, and persistence.
- Do not introduce new patterns, abstractions, interfaces, factories, or generic frameworks without a concrete need and a stated reason why existing ones are insufficient.
- Prefer dependency injection over service location or manual construction. Avoid circular dependencies.
- Never add a dependency without stating why existing ones don't work. Avoid obsolete or deprecated APIs.
- No breaking changes to public APIs without explicit authorization. Keep public surfaces minimal and don't leak internals.
- Avoid speculative abstractions and premature generalization. Do not build infrastructure for hypothetical future requirements.

## Error handling and logging
- Don't use exceptions for normal control flow.
- Catch only when you can handle, enrich with context, or translate into a meaningful application error. Never catch bare `Exception` without a specific reason and handling strategy.
- Rethrow with `throw;`, never `throw ex;`.
- Never return null or default values to hide unexpected failures.
- Use structured logging with named properties, not string interpolation. Never log secrets, tokens, or personal data. Don't log the same exception at multiple layers.

## Performance
- Prefer simple, readable implementations. Don't add caching, pooling, or concurrency without clear justification.
- Avoid N+1 queries, redundant DB/network calls, repeated LINQ enumeration, and needless allocations.
- Use async APIs for I/O. Consider algorithmic complexity on large datasets.

## C# conventions
- Follow the project's target framework, language version, and existing conventions first; use modern C# features where supported.
- Use file-scoped namespaces (`namespace MyNamespace;`).
- Use `async`/`await` correctly: no `async void` (except event handlers), no `.Result`, `.Wait()`, or `.GetAwaiter().GetResult()`.
- Pass `CancellationToken` through asynchronous call chains when supported by the surrounding APIs. Avoid `Task.Run` for naturally asynchronous I/O operations.
- Prefer `readonly`, `init`-only properties, and immutable structures where appropriate.
- Prefer pattern matching over verbose type checks and casts when it improves readability.
- Use expression-bodied members for simple cases, block bodies for complex logic.
- Use LINQ for straightforward transformations; explicit loops when clearer or faster.
- Dispose `IDisposable`/`IAsyncDisposable` with `using` / `await using` declarations.

## Reporting
- At the end state: what changed, why, how it was verified, known risks/follow-ups.
- If something couldn't be verified, say so explicitly instead of implying it works.