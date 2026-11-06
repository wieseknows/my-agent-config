---
description: Full ticket pipeline: plan, implement, review, test
---
1. Read the ticket text I provide. Write a short plan (files, risks, open questions). Wait for my "ok" only if there are open questions.
2. Invoke the `implementer` subagent with the plan.
3. Invoke the `reviewer` subagent on the resulting diff.
4. If there are blocker/major findings: send them back to `implementer`, then re-run `reviewer`. Maximum 2 iterations, then report what's left.
5. Invoke the `test-writer` subagent for the final change.
6. Run build + tests + linters. Fix failures via the proper subagent.
7. Final report: changes, review findings and how they were resolved, test results, risks.