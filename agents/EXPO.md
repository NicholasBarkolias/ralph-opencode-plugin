# React Native + Expo Guidelines (TanStack Ecosystem)

## TanStack Packages

Always prefer TanStack packages where applicable:
- **Expo Router** - File-based routing (Expo's official router)
- **TanStack Query** - Data fetching, caching, and server state
- **TanStack Form** - Type-safe form management
- **TanStack Virtual** - Virtualized lists (for FlashList alternative)

Note: Use Expo Router for navigation (not TanStack Router) as it's the official Expo solution.

## Project Structure

```
mobile/
├── app/                    # Expo Router file-based routing
│   ├── _layout.tsx         # Root layout with providers
│   ├── index.tsx           # Home screen
│   ├── (tabs)/             # Tab navigator group
│   │   ├── _layout.tsx     # Tab layout
│   │   ├── index.tsx       # Tab 1
│   │   └── profile.tsx     # Tab 2
│   └── tasks/
│       ├── index.tsx       # Tasks list
│       └── [id].tsx        # Task detail (dynamic route)
├── src/
│   ├── components/
│   │   ├── ui/             # Reusable UI components
│   │   └── features/       # Feature-specific components
│   ├── hooks/
│   ├── api/                # TanStack Query functions
│   ├── types/
│   └── utils/
├── assets/                 # Static assets
├── package.json
├── app.json
└── tsconfig.json
```

## Required Dependencies

```json
{
  "dependencies": {
    "expo": "~50.x",
    "expo-router": "~3.x",
    "@tanstack/react-query": "^5.x",
    "@tanstack/react-form": "^0.x",
    "@react-native-async-storage/async-storage": "^1.x"
  }
}
```

## TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["ESNext"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "jsx": "react-native",
    "jsxImportSource": "react",
    "baseUrl": "./",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@api/*": ["./src/api/*"],
      "@types/*": ["./src/types/*"],
      "@utils/*": ["./src/utils/*"]
    }
  },
  "include": ["**/*.ts", "**/*.tsx"]
}
```

## TanStack Query Setup with Expo

```typescript
// app/_layout.tsx
import { Slot } from 'expo-router';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState } from 'react';

export default function RootLayout() {
  const [queryClient] = useState(
    () => new QueryClient({
      defaultOptions: {
        queries: {
          staleTime: 1000 * 60 * 5, // 5 minutes
          retry: 2,
          // Good defaults for mobile
          refetchOnWindowFocus: false,
          refetchOnReconnect: true,
        },
      },
    })
  );

  return (
    <QueryClientProvider client={queryClient}>
      <Slot />
    </QueryClientProvider>
  );
}
```

## API Integration with TanStack Query

```typescript
// src/api/client.ts
const API_BASE = __DEV__ 
  ? 'http://localhost:4000/api' 
  : 'https://your-api.com/api';

export async function fetchApi<T>(
  endpoint: string, 
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });

  if (!response.ok) {
    throw new Error(`API Error: ${response.status}`);
  }

  return response.json();
}

// src/api/tasks.ts
import { queryOptions, useMutation, useQueryClient } from '@tanstack/react-query';
import { fetchApi } from './client';

export interface Task {
  id: number;
  title: string;
  completed: boolean;
  inserted_at: string;
}

export interface TasksResponse {
  data: Task[];
}

// Query Options
export const tasksQueryOptions = queryOptions({
  queryKey: ['tasks'],
  queryFn: () => fetchApi<TasksResponse>('/tasks'),
});

export const taskQueryOptions = (id: number) => queryOptions({
  queryKey: ['tasks', id],
  queryFn: () => fetchApi<{ data: Task }>(`/tasks/${id}`),
});

// Mutations
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

export function useUpdateTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, ...task }: { id: number } & Partial<Task>) =>
      fetchApi<{ data: Task }>(`/tasks/${id}`, {
        method: 'PUT',
        body: JSON.stringify({ task }),
      }),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
      queryClient.invalidateQueries({ queryKey: ['tasks', variables.id] });
    },
  });
}

export function useDeleteTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (id: number) =>
      fetchApi<void>(`/tasks/${id}`, { method: 'DELETE' }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}
```

## Component Patterns with TanStack Query

```typescript
// src/components/features/TaskList.tsx
import { View, Text, FlatList, ActivityIndicator, Pressable } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { tasksQueryOptions, useDeleteTask, Task } from '@api/tasks';
import { TaskItem } from './TaskItem';

export function TaskList() {
  const { data, isLoading, error, refetch, isRefetching } = useQuery(tasksQueryOptions);
  const deleteTask = useDeleteTask();

  if (isLoading) return <ActivityIndicator testID="loading" />;
  if (error) return <Text testID="error">Error: {error.message}</Text>;

  return (
    <FlatList
      testID="task-list"
      data={data?.data}
      keyExtractor={(item) => item.id.toString()}
      renderItem={({ item }) => (
        <TaskItem 
          task={item}
          onDelete={() => deleteTask.mutate(item.id)}
          isDeleting={deleteTask.isPending}
        />
      )}
      refreshing={isRefetching}
      onRefresh={refetch}
      ListEmptyComponent={<Text>No tasks found</Text>}
    />
  );
}
```

## Expo Router Navigation

```typescript
// app/index.tsx
import { router } from 'expo-router';
import { View, Text, Pressable, StyleSheet } from 'react-native';

export default function HomeScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome to the App</Text>
      <Pressable 
        style={styles.button}
        onPress={() => router.push('/tasks')}
      >
        <Text style={styles.buttonText}>View Tasks</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  button: { backgroundColor: '#007AFF', padding: 16, borderRadius: 8 },
  buttonText: { color: 'white', fontWeight: '600' },
});

// app/tasks/[id].tsx - Dynamic route
import { useLocalSearchParams } from 'expo-router';
import { View, Text, ActivityIndicator } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { taskQueryOptions } from '@api/tasks';

export default function TaskDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { data, isLoading, error } = useQuery(taskQueryOptions(Number(id)));

  if (isLoading) return <ActivityIndicator />;
  if (error) return <Text>Error: {error.message}</Text>;

  return (
    <View style={{ flex: 1, padding: 16 }}>
      <Text style={{ fontSize: 24 }}>{data?.data.title}</Text>
      <Text>Status: {data?.data.completed ? 'Done' : 'Pending'}</Text>
    </View>
  );
}
```

## TanStack Form Pattern for React Native

```typescript
// src/components/features/TaskForm.tsx
import { View, Text, TextInput, Pressable, StyleSheet } from 'react-native';
import { useForm } from '@tanstack/react-form';
import { useCreateTask } from '@api/tasks';

export function TaskForm() {
  const createTask = useCreateTask();
  
  const form = useForm({
    defaultValues: {
      title: '',
      completed: false,
    },
    onSubmit: async ({ value }) => {
      await createTask.mutateAsync(value);
      form.reset();
    },
  });

  return (
    <View style={styles.container}>
      <form.Field
        name="title"
        validators={{
          onChange: ({ value }) =>
            value.length < 3 ? 'Title must be at least 3 characters' : undefined,
        }}
      >
        {(field) => (
          <View style={styles.fieldContainer}>
            <TextInput
              style={styles.input}
              value={field.state.value}
              onChangeText={field.handleChange}
              onBlur={field.handleBlur}
              placeholder="Enter task title"
            />
            {field.state.meta.errors.length > 0 && (
              <Text style={styles.error}>
                {field.state.meta.errors.join(', ')}
              </Text>
            )}
          </View>
        )}
      </form.Field>
      
      <Pressable
        style={[styles.button, createTask.isPending && styles.buttonDisabled]}
        onPress={form.handleSubmit}
        disabled={createTask.isPending}
      >
        <Text style={styles.buttonText}>
          {createTask.isPending ? 'Creating...' : 'Create Task'}
        </Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { padding: 16 },
  fieldContainer: { marginBottom: 16 },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  error: { color: 'red', marginTop: 4 },
  button: {
    backgroundColor: '#007AFF',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonDisabled: { opacity: 0.5 },
  buttonText: { color: 'white', fontWeight: '600' },
});
```

## Optimistic Updates Pattern

```typescript
// src/api/tasks.ts
export function useToggleTaskComplete() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, completed }: { id: number; completed: boolean }) =>
      fetchApi<{ data: Task }>(`/tasks/${id}`, {
        method: 'PUT',
        body: JSON.stringify({ task: { completed } }),
      }),
    // Optimistic update
    onMutate: async ({ id, completed }) => {
      await queryClient.cancelQueries({ queryKey: ['tasks'] });
      
      const previousTasks = queryClient.getQueryData<TasksResponse>(['tasks']);
      
      queryClient.setQueryData<TasksResponse>(['tasks'], (old) => ({
        data: old?.data.map(task =>
          task.id === id ? { ...task, completed } : task
        ) ?? [],
      }));
      
      return { previousTasks };
    },
    onError: (_, __, context) => {
      // Rollback on error
      if (context?.previousTasks) {
        queryClient.setQueryData(['tasks'], context.previousTasks);
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}
```

## Offline Support with Query Persistence

```typescript
// app/_layout.tsx
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister';
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 60 * 24, // 24 hours
      staleTime: 1000 * 60 * 5,
    },
  },
});

const asyncStoragePersister = createAsyncStoragePersister({
  storage: AsyncStorage,
});

export default function RootLayout() {
  return (
    <PersistQueryClientProvider
      client={queryClient}
      persistOptions={{ persister: asyncStoragePersister }}
    >
      <Slot />
    </PersistQueryClientProvider>
  );
}
```

## Testing with TanStack Query

```typescript
// __tests__/TaskList.test.tsx
import { render, screen, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { TaskList } from '../src/components/features/TaskList';
import * as tasksApi from '../src/api/tasks';

jest.mock('../src/api/tasks', () => ({
  ...jest.requireActual('../src/api/tasks'),
  tasksQueryOptions: {
    queryKey: ['tasks'],
    queryFn: jest.fn(),
  },
}));

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

describe('TaskList', () => {
  it('renders tasks from API', async () => {
    (tasksApi.tasksQueryOptions.queryFn as jest.Mock).mockResolvedValue({
      data: [{ id: 1, title: 'Test Task', completed: false, inserted_at: '' }]
    });

    render(<TaskList />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText('Test Task')).toBeTruthy();
    });
  });

  it('shows loading indicator', () => {
    (tasksApi.tasksQueryOptions.queryFn as jest.Mock).mockImplementation(
      () => new Promise(() => {})
    );
    render(<TaskList />, { wrapper: createWrapper() });
    expect(screen.getByTestId('loading')).toBeTruthy();
  });
});
```

## Platform-Specific Code

```typescript
import { Platform } from 'react-native';

const isIOS = Platform.OS === 'ios';
const isAndroid = Platform.OS === 'android';

// Platform-specific styles
const styles = StyleSheet.create({
  shadow: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
    },
    android: {
      elevation: 4,
    },
  }),
});
```

## Constants Configuration

```typescript
// src/constants/config.ts
export const config = {
  API_BASE: __DEV__ 
    ? 'http://localhost:4000/api' 
    : 'https://your-api.com/api',
  QUERY_STALE_TIME: 1000 * 60 * 5, // 5 minutes
  QUERY_GC_TIME: 1000 * 60 * 60, // 1 hour
} as const;

// src/constants/queryKeys.ts
export const queryKeys = {
  tasks: {
    all: ['tasks'] as const,
    detail: (id: number) => ['tasks', id] as const,
  },
  users: {
    all: ['users'] as const,
    detail: (id: number) => ['users', id] as const,
  },
} as const;
```

## Expo Config

```json
{
  "expo": {
    "name": "My App",
    "slug": "my-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.myapp.app"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.myapp.app"
    },
    "plugins": [
      "expo-router"
    ]
  }
}
```
