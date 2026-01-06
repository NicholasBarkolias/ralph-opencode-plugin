# Ralph Loop Agent Guidelines

## Core Principles

1. **One Task Per Iteration** - Never do multiple things at once
2. **Verify Before Commit** - All changes must pass verification
3. **Git Is Truth** - Read git diff and history to understand state
4. **Update Plan** - Always update plan.md after completing a task
5. **Learn & Document** - Add critical discoveries to this file

## Project Context

- **Backend**: Elixir/Phoenix with Ecto
- **Frontend**: React with TypeScript (in assets/ or frontend/)
- **Database**: PostgreSQL
- **Build**: esbuild (Phoenix 1.6+)

## Verification Commands

```bash
# Phoenix
mix compile --warnings-as-errors
mix test
mix format --check-formatted
mix credo --strict

# React/TypeScript
cd assets && npm run typecheck
cd assets && npm test
cd assets && npm run lint
```

## Commit Convention

Format: `[area] brief description`

Examples:
- `[phoenix] add user authentication context`
- `[react] create TaskList component`
- `[ecto] add migration for tasks table`
- `[api] implement REST endpoint for tasks`

## Critical Learnings

<!-- Ralph will append learnings here -->
