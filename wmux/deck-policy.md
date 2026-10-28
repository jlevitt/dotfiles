<!-- deck-policy.md — binding standing rules for the wmux orchestrator.
Write ONE rule per line as a bullet. These are authoritative: when a rule here
answers a question the orchestrator would otherwise escalate, it acts on the
rule and cites it instead of asking you. Keep each rule short and unambiguous.
Rules cannot grant the orchestrator new tools or override safety — risky or
irreversible actions still come to you. Delete these examples and add your own. -->

- Work happens in an isolated git worktree under the designated worktrees folder — never the product's main checkout. If a task doesn't say where, this rule answers it.
- Prefer reusing an existing idle pane over spawning a new one; spawn only when nothing is free or the work must genuinely run in parallel.
