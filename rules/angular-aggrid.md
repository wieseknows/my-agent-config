# Angular / TypeScript standards
- `strict` TypeScript; no `any` (use `unknown` + narrowing); explicit return types on public methods.
- Standalone components, `OnPush`, signals or RxJS consistently with the existing code of the module.
- RxJS: no nested subscribes; unsubscribe via `takeUntilDestroyed`/async pipe; every stream has error handling (`catchError`) with a user-visible or logged outcome.
- HTTP only through services; typed DTOs; no business logic in components.
- All user-facing text through the localization system; never hardcode strings.
- ag-Grid: column defs and grid options in a typed factory/service; persisted grid state (columns, filters, sort) goes through the existing grid settings service; avoid per-cell heavy renderers, use `valueGetter`/`valueFormatter` where possible.
- Reuse shared components before creating new ones; search the shared module first.