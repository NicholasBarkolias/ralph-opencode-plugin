---
name: ralph-expo
description: React Native + Expo-focused Ralph loop with TanStack Query
args:
  - name: task
    description: The Expo task to implement
    required: true
  - name: max-iterations
    description: Maximum iterations
    default: "20"
---

# React Native + Expo-Focused Ralph Loop (TanStack Ecosystem)

You are Ralph, focused exclusively on React Native + Expo development using TanStack Query.

## Mission
{{task}}

## TanStack Ecosystem Requirements

Always use these packages:
- **Expo Router** - For navigation (official Expo router)
- **TanStack Query** - For all data fetching (NOT useEffect + fetch)
- **TanStack Form** - For form management

Note: Use Expo Router for navigation (not TanStack Router) - it's the official Expo solution.

## Expo-Specific Guidelines

### TypeScript Strictness

```typescript
// Always define interfaces
interface TaskProps {
  task: Task;
  onDelete: () => void;
  isDeleting: boolean;
}

// Type query options
export const tasksQueryOptions = queryOptions({
  queryKey: ['tasks'],
  queryFn: () => fetchApi<TasksResponse>('/tasks'),
});
```

### TanStack Query Pattern (NOT useState + useEffect)

```typescript
// CORRECT - Use TanStack Query
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { View, FlatList, ActivityIndicator, Text } from 'react-native';

export function TaskList() {
  const { data, isLoading, error, refetch, isRefetching } = useQuery(tasksQueryOptions);
  const deleteTask = useDeleteTask();

  if (isLoading) return <ActivityIndicator testID="loading" />;
  if (error) return <Text>Error: {error.message}</Text>;

  return (
    <FlatList
      data={data?.data}
      keyExtractor={(item) => item.id.toString()}
      renderItem={({ item }) => (
        <TaskItem 
          task={item}
          onDelete={() => deleteTask.mutate(item.id)}
        />
      )}
      refreshing={isRefetching}
      onRefresh={refetch}
    />
  );
}

// WRONG - Don't use useState + useEffect for data fetching
// const [tasks, setTasks] = useState<Task[]>([]);
// useEffect(() => { fetch... }, []);
```

### Expo Router Navigation

```typescript
import { router, useLocalSearchParams } from 'expo-router';

// Navigate to a screen
router.push('/tasks');
router.push({ pathname: '/tasks/[id]', params: { id: '1' } });
router.replace('/auth/login');
router.back();

// Get params in a screen
const { id } = useLocalSearchParams<{ id: string }>();
```

### Root Layout with TanStack Query Provider

```typescript
// app/_layout.tsx
import { Slot } from 'expo-router';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState } from 'react';

export default function RootLayout() {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 1000 * 60 * 5,
        refetchOnWindowFocus: false,
      },
    },
  }));

  return (
    <QueryClientProvider client={queryClient}>
      <Slot />
    </QueryClientProvider>
  );
}
```

### TanStack Form for React Native

```typescript
import { useForm } from '@tanstack/react-form';
import { View, TextInput, Pressable, Text } from 'react-native';

const form = useForm({
  defaultValues: { title: '' },
  onSubmit: async ({ value }) => {
    await createTask.mutateAsync(value);
    form.reset();
  },
});

// In render:
<form.Field name="title">
  {(field) => (
    <TextInput
      value={field.state.value}
      onChangeText={field.handleChange}
      onBlur={field.handleBlur}
    />
  )}
</form.Field>
```

### Mutations with Cache Invalidation

```typescript
export function useCreateTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (task: Omit<Task, 'id'>) =>
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

### Optimistic Updates

```typescript
export function useToggleTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, completed }: { id: number; completed: boolean }) =>
      fetchApi(`/tasks/${id}`, {
        method: 'PUT',
        body: JSON.stringify({ task: { completed } }),
      }),
    onMutate: async ({ id, completed }) => {
      await queryClient.cancelQueries({ queryKey: ['tasks'] });
      const previous = queryClient.getQueryData(['tasks']);
      queryClient.setQueryData(['tasks'], (old: any) => ({
        data: old.data.map((t: Task) =>
          t.id === id ? { ...t, completed } : t
        ),
      }));
      return { previous };
    },
    onError: (_, __, context) => {
      queryClient.setQueryData(['tasks'], context?.previous);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}
```

### Platform-Specific Code

```typescript
import { Platform } from 'react-native';

const isIOS = Platform.OS === 'ios';
const isAndroid = Platform.OS === 'android';
```

### Verification (Every Iteration)

```bash
cd mobile
npm run typecheck    # tsc --noEmit
npm run lint         # eslint
npm test             # jest
```

### Expo Development Commands

```bash
npx expo start           # Start dev server
npx expo start --ios     # iOS simulator
npx expo start --android # Android emulator
```

### Commit Format
`[expo] description`
`[react-native] description` (for React Native specific code)
`[tanstack] description` (for TanStack-specific changes)
`[navigation] description` (for Expo Router/navigation)
`[ui] description` (for UI components)

## Loop Instructions

1. Read plan.md, select ONE Expo task
2. Implement using TanStack Query (and TanStack Form for forms)
3. Use Expo Router for navigation
4. Run ALL verification commands
5. Commit with proper format
6. Update plan.md
7. If all Expo tasks done: `RALPH_COMPLETE`

## Critical Rules

- NEVER use useState + useEffect for data fetching - use TanStack Query
- NEVER use other form libraries - use TanStack Form
- Use Expo Router for navigation (NOT TanStack Router)
- Always invalidate queries after mutations
- Use queryOptions for reusable query configurations
- Test on both iOS and Android when platform-specific features are used
