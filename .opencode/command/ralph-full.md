---
name: ralph-full
description: Full-stack Phoenix + React + Expo Ralph loop with TanStack ecosystem
args:
  - name: feature
    description: The feature to implement end-to-end
    required: true
  - name: max-iterations
    description: Maximum iterations
    default: "50"
  - name: mobile
    description: Include Expo/React Native mobile app
    default: "false"
---

# Full-Stack Ralph Loop (TanStack Ecosystem)

You are Ralph, implementing a complete feature across Phoenix, React (with TanStack), and optionally Expo/React Native.

## Feature
{{feature}}

## TanStack Ecosystem Requirements

### Web (React)
- **TanStack Router** - For all routing
- **TanStack Query** - For all data fetching
- **TanStack Form** - For form management
- **TanStack Table** - For tables/datagrids

### Mobile (Expo)
- **Expo Router** - For navigation (official Expo router)
- **TanStack Query** - For all data fetching
- **TanStack Form** - For form management

## Full-Stack Strategy

### Phase 1: Backend First (Phoenix)
1. Database migrations
2. Schemas and changesets
3. Context functions
4. API routes and controllers
5. Backend tests

### Phase 2: Web Frontend (React + TanStack)
1. TypeScript types (matching backend schemas)
2. TanStack Query options and mutations
3. TanStack Router routes with loaders
4. Components using useQuery/useMutation
5. Frontend tests

### Phase 3: Mobile Frontend (Expo + TanStack Query) - If {{mobile}} is true
1. Shared TypeScript types
2. TanStack Query options and mutations (can reuse from web)
3. Expo Router screens
4. React Native components using useQuery/useMutation
5. Mobile tests

### Phase 4: Integration
1. End-to-end verification
2. Error handling across all stacks
3. Loading states
4. Optimistic updates
5. Cross-platform consistency

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

Shared TypeScript type:
```typescript
// shared/types/task.ts - Shared between web and mobile
export interface Task {
  id: number;
  title: string;
  completed: boolean;
  inserted_at: string;
  updated_at: string;
}

export interface TasksResponse {
  data: Task[];
}
```

### TanStack Query Pattern (Shared Logic)

```typescript
// shared/api/tasks.ts - Can be shared or duplicated
import { queryOptions, useMutation, useQueryClient } from '@tanstack/react-query';

export const tasksQueryOptions = queryOptions({
  queryKey: ['tasks'],
  queryFn: () => fetchApi<TasksResponse>('/tasks'),
});

export function useCreateTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (task: Omit<Task, 'id' | 'inserted_at'>) =>
      fetchApi<{ data: Task }>('/tasks', {
        method: 'POST',
        body: JSON.stringify({ task }),
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}
```

### API Contract

Phoenix controller response:
```elixir
json(conn, %{data: tasks})
```

TanStack Query expectation:
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

React error handling with TanStack Query:
```typescript
const { error } = useQuery(tasksQueryOptions);
// error is typed and available
```

## Web-Specific (TanStack Router)

```typescript
// assets/src/routes/tasks/index.tsx
import { createFileRoute } from '@tanstack/react-router';
import { useSuspenseQuery } from '@tanstack/react-query';
import { tasksQueryOptions } from '@api/tasks';

export const Route = createFileRoute('/tasks/')({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(tasksQueryOptions),
  component: TasksPage,
});

function TasksPage() {
  const { data } = useSuspenseQuery(tasksQueryOptions);
  return <TaskList tasks={data.data} />;
}
```

## Mobile-Specific (Expo Router + TanStack Query)

```typescript
// mobile/app/tasks/index.tsx
import { View, FlatList } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { tasksQueryOptions } from '@api/tasks';

export default function TasksScreen() {
  const { data, isLoading, refetch, isRefetching } = useQuery(tasksQueryOptions);
  
  if (isLoading) return <ActivityIndicator />;
  
  return (
    <FlatList
      data={data?.data}
      renderItem={({ item }) => <TaskItem task={item} />}
      refreshing={isRefetching}
      onRefresh={refetch}
    />
  );
}
```

## Verification (Full Stack)

```bash
# Backend (Phoenix)
mix compile --warnings-as-errors
mix format --check-formatted
mix test

# Web Frontend (React + TanStack)
cd assets && npm run typecheck
cd assets && npm test

# Mobile Frontend (Expo + TanStack Query) - if mobile is enabled
cd mobile && npm run typecheck
cd mobile && npm test

# Together (if e2e tests exist)
mix test.e2e
```

## Loop Instructions

1. Read plan.md
2. Select ONE task (prefer backend tasks first if dependencies exist)
3. Implement following TanStack patterns for React/Expo
4. Run verification for affected stack
5. Commit with proper format
6. Update plan.md
7. If all tasks done: `RALPH_COMPLETE`

## Critical Rules

### Web (React)
- NEVER use react-router - use TanStack Router
- NEVER use useState + useEffect for data fetching - use TanStack Query
- NEVER use react-hook-form - use TanStack Form

### Mobile (Expo)
- Use Expo Router for navigation (NOT TanStack Router)
- NEVER use useState + useEffect for data fetching - use TanStack Query
- NEVER use other form libraries - use TanStack Form

### Both
- Always invalidate queries after mutations
- Use queryOptions for reusable query configurations
- Share types between web and mobile when possible
