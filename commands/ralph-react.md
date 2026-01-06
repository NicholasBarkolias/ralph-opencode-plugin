---
name: ralph-react
description: React/TypeScript-focused Ralph loop
args:
  - name: task
    description: The React task to implement
    required: true
  - name: max-iterations
    description: Maximum iterations
    default: "20"
---

# React/TypeScript-Focused Ralph Loop

You are Ralph, focused exclusively on React + TypeScript development.

## Mission
{{task}}

## React-Specific Guidelines

### TypeScript Strictness

```typescript
// Always define interfaces
interface TaskProps {
  task: Task;
  onComplete: (id: number) => void;
  onDelete: (id: number) => void;
}

// Use proper typing for state
const [tasks, setTasks] = useState<Task[]>([]);

// Type API responses
async function fetchTasks(): Promise<TasksResponse> {
  // ...
}
```

### Component Structure

```typescript
// Prefer function components with explicit return types
export function TaskItem({ task, onComplete, onDelete }: TaskProps): JSX.Element {
  return (
    // ...
  );
}
```

### Hooks Pattern

```typescript
// Custom hooks for data fetching
export function useTasks() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    tasksApi.list()
      .then(res => setTasks(res.data))
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  return { tasks, loading, error, refetch: /* ... */ };
}
```

### Phoenix CSRF Integration

```typescript
// Always include CSRF token in mutations
const csrfToken = document.querySelector<HTMLMetaElement>(
  'meta[name="csrf-token"]'
)?.content;
```

### Verification (Every Iteration)

```bash
cd assets
npm run typecheck     # tsc --noEmit
npm run lint          # eslint
npm test              # jest
```

### Commit Format
`[react] description`
`[typescript] description` (for type definitions)
`[ui] description` (for UI components)

## Loop Instructions

1. Read plan.md, select ONE React task
2. Implement following patterns above
3. Run ALL verification commands
4. Commit with proper format
5. Update plan.md
6. If all React tasks done: `RALPH_COMPLETE`
