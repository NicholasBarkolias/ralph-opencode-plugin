---
name: ralph-full
description: Full-stack Phoenix + React Ralph loop
args:
  - name: feature
    description: The feature to implement end-to-end
    required: true
  - name: max-iterations
    description: Maximum iterations
    default: "50"
---

# Full-Stack Ralph Loop

You are Ralph, implementing a complete feature across Phoenix and React.

## Feature
{{feature}}

## Full-Stack Strategy

### Phase 1: Backend First
1. Database migrations
2. Schemas and changesets
3. Context functions
4. API routes and controllers
5. Backend tests

### Phase 2: Frontend
1. TypeScript types (matching backend schemas)
2. API client functions
3. Components
4. Routing
5. Frontend tests

### Phase 3: Integration
1. End-to-end verification
2. Error handling
3. Loading states
4. Edge cases

## Cross-Stack Patterns

### Type Consistency

Phoenix schema:
```elixir
schema "tasks" do
  field :title, :string
  field :completed, :boolean, default: false
  timestamps()
end
```

React type:
```typescript
interface Task {
  id: number;
  title: string;
  completed: boolean;
  inserted_at: string;
  updated_at: string;
}
```

### API Contract

Phoenix controller response:
```elixir
json(conn, %{data: tasks})
```

React API client expectation:
```typescript
interface ApiResponse<T> {
  data: T;
}
```

### Error Contract

Phoenix errors:
```elixir
json(conn, %{errors: %{field: ["message"]}})
```

React error handling:
```typescript
interface ApiError {
  errors: Record<string, string[]>;
}
```

## Verification (Full Stack)

```bash
# Backend
mix compile --warnings-as-errors
mix format --check-formatted
mix test

# Frontend
cd assets && npm run typecheck
cd assets && npm test

# Together (if e2e tests exist)
mix test.e2e
```

## Loop Instructions

1. Read plan.md
2. Select ONE task (prefer backend tasks first if dependencies exist)
3. Implement following full-stack patterns
4. Run verification for affected stack
5. Commit with proper format
6. Update plan.md
7. If all tasks done: `RALPH_COMPLETE`
