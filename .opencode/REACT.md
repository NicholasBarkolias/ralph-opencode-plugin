# React + TypeScript Guidelines (TanStack Ecosystem)

## TanStack Packages

Always prefer TanStack packages where applicable:
- **TanStack Router** - Type-safe file-based routing
- **TanStack Query** - Data fetching, caching, and server state
- **TanStack Form** - Type-safe form management
- **TanStack Table** - Headless table/datagrid logic
- **TanStack Virtual** - Virtualized lists and grids

## Project Structure

```
assets/                 # or frontend/ depending on setup
├── src/
│   ├── main.tsx        # Entry point
│   ├── routes/         # TanStack Router file-based routes
│   │   ├── __root.tsx  # Root layout
│   │   ├── index.tsx   # Home route
│   │   ├── tasks/
│   │   │   ├── index.tsx
│   │   │   └── $taskId.tsx
│   │   └── -components/ # Route-specific components (excluded from routing)
│   ├── components/
│   │   ├── ui/         # Reusable UI components
│   │   └── features/   # Feature-specific components
│   ├── hooks/
│   ├── api/            # TanStack Query functions
│   ├── types/
│   └── utils/
├── package.json
└── tsconfig.json
```

## Required Dependencies

```json
{
  "dependencies": {
    "@tanstack/react-query": "^5.x",
    "@tanstack/react-router": "^1.x",
    "@tanstack/react-form": "^0.x",
    "@tanstack/react-table": "^8.x",
    "@tanstack/react-virtual": "^3.x"
  }
}
```

## TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["DOM", "DOM.Iterable", "ES2020"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "jsx": "react-jsx",
    "baseUrl": "./src",
    "paths": {
      "@/*": ["./*"],
      "@components/*": ["./components/*"],
      "@hooks/*": ["./hooks/*"],
      "@api/*": ["./api/*"]
    }
  },
  "include": ["src/**/*"]
}
```

## TanStack Query Setup

```typescript
// main.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider, createRouter } from '@tanstack/react-router';
import { routeTree } from './routeTree.gen';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 1,
    },
  },
});

const router = createRouter({ 
  routeTree,
  context: { queryClient },
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  );
}
```

## API Integration with TanStack Query

```typescript
// api/client.ts
const API_BASE = '/api';

function getCsrfToken(): string {
  return document.querySelector<HTMLMetaElement>(
    'meta[name="csrf-token"]'
  )?.content ?? '';
}

export async function fetchApi<T>(
  endpoint: string, 
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': getCsrfToken(),
      ...options?.headers,
    },
  });

  if (!response.ok) {
    throw new Error(`API Error: ${response.status}`);
  }

  return response.json();
}

// api/tasks.ts
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

// Query Options (for use with useQuery or router loaders)
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

## TanStack Router Routes

```typescript
// routes/__root.tsx
import { createRootRouteWithContext, Outlet } from '@tanstack/react-router';
import type { QueryClient } from '@tanstack/react-query';

interface RouterContext {
  queryClient: QueryClient;
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: () => (
    <div>
      <nav>{/* Navigation */}</nav>
      <main>
        <Outlet />
      </main>
    </div>
  ),
});

// routes/tasks/index.tsx
import { createFileRoute } from '@tanstack/react-router';
import { useSuspenseQuery } from '@tanstack/react-query';
import { tasksQueryOptions } from '@api/tasks';
import { TaskList } from './-components/TaskList';

export const Route = createFileRoute('/tasks/')({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(tasksQueryOptions),
  component: TasksPage,
});

function TasksPage() {
  const { data } = useSuspenseQuery(tasksQueryOptions);
  
  return <TaskList tasks={data.data} />;
}

// routes/tasks/$taskId.tsx
import { createFileRoute } from '@tanstack/react-router';
import { useSuspenseQuery } from '@tanstack/react-query';
import { taskQueryOptions } from '@api/tasks';

export const Route = createFileRoute('/tasks/$taskId')({
  loader: ({ context: { queryClient }, params: { taskId } }) =>
    queryClient.ensureQueryData(taskQueryOptions(Number(taskId))),
  component: TaskDetailPage,
});

function TaskDetailPage() {
  const { taskId } = Route.useParams();
  const { data } = useSuspenseQuery(taskQueryOptions(Number(taskId)));
  
  return <div>{data.data.title}</div>;
}
```

## Component Patterns with TanStack Query

```typescript
// components/features/TaskList.tsx
import { useQuery } from '@tanstack/react-query';
import { tasksQueryOptions, useDeleteTask } from '@api/tasks';
import { TaskItem } from './TaskItem';

export function TaskList() {
  const { data, isLoading, error } = useQuery(tasksQueryOptions);
  const deleteTask = useDeleteTask();

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <ul>
      {data?.data.map(task => (
        <TaskItem 
          key={task.id} 
          task={task}
          onDelete={() => deleteTask.mutate(task.id)}
        />
      ))}
    </ul>
  );
}
```

## TanStack Form Pattern

```typescript
// components/features/TaskForm.tsx
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
    <form
      onSubmit={(e) => {
        e.preventDefault();
        e.stopPropagation();
        form.handleSubmit();
      }}
    >
      <form.Field
        name="title"
        validators={{
          onChange: ({ value }) =>
            value.length < 3 ? 'Title must be at least 3 characters' : undefined,
        }}
      >
        {(field) => (
          <div>
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              onBlur={field.handleBlur}
            />
            {field.state.meta.errors.length > 0 && (
              <span>{field.state.meta.errors.join(', ')}</span>
            )}
          </div>
        )}
      </form.Field>
      
      <button type="submit" disabled={createTask.isPending}>
        {createTask.isPending ? 'Creating...' : 'Create Task'}
      </button>
    </form>
  );
}
```

## TanStack Table Pattern

```typescript
// components/features/TaskTable.tsx
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from '@tanstack/react-table';
import type { Task } from '@api/tasks';

const columnHelper = createColumnHelper<Task>();

const columns = [
  columnHelper.accessor('id', {
    header: 'ID',
    cell: info => info.getValue(),
  }),
  columnHelper.accessor('title', {
    header: 'Title',
    cell: info => info.getValue(),
  }),
  columnHelper.accessor('completed', {
    header: 'Status',
    cell: info => info.getValue() ? 'Done' : 'Pending',
  }),
];

interface TaskTableProps {
  tasks: Task[];
}

export function TaskTable({ tasks }: TaskTableProps) {
  const table = useReactTable({
    data: tasks,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <table>
      <thead>
        {table.getHeaderGroups().map(headerGroup => (
          <tr key={headerGroup.id}>
            {headerGroup.headers.map(header => (
              <th key={header.id}>
                {flexRender(header.column.columnDef.header, header.getContext())}
              </th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody>
        {table.getRowModel().rows.map(row => (
          <tr key={row.id}>
            {row.getVisibleCells().map(cell => (
              <td key={cell.id}>
                {flexRender(cell.column.columnDef.cell, cell.getContext())}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

## Testing with TanStack Query

```typescript
// __tests__/TaskList.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { TaskList } from '../components/features/TaskList';
import * as tasksApi from '../api/tasks';

// Mock the query options
jest.mock('../api/tasks', () => ({
  ...jest.requireActual('../api/tasks'),
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
      data: [{ id: 1, title: 'Test Task', completed: false }]
    });

    render(<TaskList />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText('Test Task')).toBeInTheDocument();
    });
  });
});
```

## Navigation with TanStack Router

```typescript
import { Link, useNavigate } from '@tanstack/react-router';

// Declarative navigation
<Link to="/tasks/$taskId" params={{ taskId: '1' }}>
  View Task
</Link>

// Programmatic navigation
const navigate = useNavigate();
navigate({ to: '/tasks/$taskId', params: { taskId: '1' } });

// With search params
<Link to="/tasks" search={{ filter: 'completed' }}>
  Completed Tasks
</Link>
```
