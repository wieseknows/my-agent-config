# C# / .NET standards
- Nullable reference types on; no `!` suppression without a comment explaining why.
- Async all the way: no `.Result`/`.Wait()`; accept and pass `CancellationToken` through every async chain; `ConfigureAwait(false)` in library code.
- DI via constructor injection; depend on interfaces at boundaries; no service locator, no static state.
- Options pattern for configuration; no magic strings/numbers.
- Logging: structured (`ILogger<T>`, message templates, no string interpolation); never log secrets/PII.
- Exceptions: catch specific types, rethrow with `throw;`, wrap with context only at layer boundaries. Use domain-specific exceptions or Result types for expected failures.
- EF/SQL: no queries in loops, project only needed columns, `AsNoTracking` for reads.
- Excel/file import: validate everything, collect all row errors with row/column location, never fail on the first error unless the file is structurally unreadable.
- Tests: xUnit + FluentAssertions (or whatever the repo already uses); Arrange-Act-Assert; no real I/O in unit tests.