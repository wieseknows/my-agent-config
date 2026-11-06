# Error handling for all async code
- Every async operation must have a defined failure path: what the user/caller sees, what is logged, whether it is retried.
- Retries only for idempotent operations, with backoff and a max attempt count; never retry validation or 4xx errors.
- Timeouts and cancellation on all external calls (HTTP, DB, Azure Batch, storage).
- Fire-and-forget is forbidden unless wrapped with logging of failures.
- Errors crossing a layer boundary carry context (operation, ids) but never secrets.
- Never return a success value on partial failure without reporting what failed.