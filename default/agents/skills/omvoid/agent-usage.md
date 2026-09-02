# AI agent usage in the bar

A waybar module shows how much of each AI coding subscription is used. Three
layers, deliberately decoupled — adding an agent touches none of the plumbing.

```
bin/omvoid-agent-usage-<id>   collectors, one per agent, each prints one JSON record
bin/omvoid-agent-usage-update dispatcher: runs them all, writes the records
config/waybar/scripts/waybar-agent-usage.py   display: reads records, prints waybar JSON
```

Records land in `~/.local/state/omvoid/agents/usage/<id>.json`. The display
renders whatever it finds there and knows nothing about any particular agent.

## Adding an agent

Drop an executable `bin/omvoid-agent-usage-<id>` that prints one record:

```json
{"id":"codex","name":"Codex","plan":"Plus",
 "limits":[{"label":"Session (5h)","percent":0.62,"resetsAt":"2026-09-03T06:00:00Z"}],
 "limitsStatus":"",
 "today":{"tokens":4200000,"input":300,"output":51000,"cacheRead":4100000,"cacheWrite":48700,"messages":37},
 "weekTokens":19000000,
 "recentDays":[{"date":"2026-09-02","tokens":4200000,"messages":37}],
 "byModel":[{"model":"gpt-5-codex","tokens":19000000}]}
```

Only `id` and `today.tokens` are required. `percent` is a fraction (0..1), not a
percentage. Neither the dispatcher nor the waybar module needs editing.

## Rules a collector must follow

- **Print nothing and exit 0 when the agent is not in use.** The dispatcher reads
  that as "absent", removes any stale record, and reports no error. "In use"
  means real data: a directory existing is not enough — a wrapper creates
  `~/.codex` on its very first run, long before any usage exists.
- **Never trigger a lazy wrapper.** The agent CLIs are on PATH as wrappers that
  download on first run. A background refresh every minute must not pull down
  hundreds of megabytes for a tool nobody uses. Gate on evidence of real use
  before invoking the CLI.
- **Cache.** Transcripts run to hundreds of megabytes; they cannot be re-read on
  every bar tick. Both collectors key a per-file cache on size and mtime, so only
  the one or two files being written get re-parsed. Cold scan ~1 s, warm ~0.1 s.
- **Deduplicate.** One assistant message appears in a Claude transcript several
  times as the reply streams, each copy carrying the full `usage`. Without
  deduplication by `message.id` the totals came out 2.2× too high. Codex has the
  mirror-image trap: `total_token_usage` is cumulative per session, so only
  `last_token_usage` may be summed, and its cache counts are already inside
  `input_tokens`.
- **Drop limit windows that have reset.** A cached "78% of the 5-hour window"
  describes a period that is over once `resetsAt` passes; showing it is worse
  than showing nothing.

## Where the numbers come from

| | local usage | authoritative limits |
|---|---|---|
| claude | `~/.claude/projects/**/*.jsonl` | `GET https://api.anthropic.com/api/oauth/usage`, bearer token from `~/.claude/.credentials.json`, header `anthropic-beta: oauth-2025-04-20` |
| codex | `~/.codex/sessions`, `archived_sessions` | `codex … app-server` over JSON-RPC: `initialize` → `account/read` → `account/rateLimits/read` |

The Claude token lives about eight hours and is refreshed only when the
**terminal** `claude` runs. The desktop app keeps its session elsewhere and does
not touch that file, so on a desktop-only machine the percentages freeze while
the token counts keep working. That is expected: the module says
`сессия CLI истекла` and falls back to local numbers.

The module refreshes every 60 s and on click (`pkill -RTMIN+12 waybar`). An agent
with no limits and no tokens this week is not drawn at all.
