# React + TypeScript Guidelines (Phoenix Integration)

## Project Structure

```
assets/                 # or frontend/ depending on setup
├── js/
│   ├── app.tsx         # Entry point
│   ├── components/
│   │   ├── ui/         # Reusable UI components
│   │   └── features/   # Feature-specific components
│   ├── hooks/
│   ├── api/            # API client functions
│   ├── types/
│   └── utils/
├── css/
├── package.json
└── tsconfig.json
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
    "baseUrl": "./js",
    "paths": {
      "@/*": ["./*"],
      "@components/*": ["./components/*"],
      "@hooks/*": ["./hooks/*"],
      "@api/*": ["./api/*"]
    }
  },
  "include": ["js/**/*"]
}
```

## API Integration Pattern

```typescript
// api/client.ts
const API_BASE = '/api';

async function fetchApi<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const csrfToken = document.querySelector<HTMLMetaElement>(
    'meta[name="csrf-token"]'
  )?.content;

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken ?? '',
      ...options?.headers,
    },
  });

  if (!response.ok) {
    throw new Error(`API Error: ${response.status}`);
  }

  return response.json();
}

// api/tasks.ts
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

export const tasksApi = {
  list: () => fetchApi<TasksResponse>('/tasks'),
  get: (id: number) => fetchApi<{ data: Task }>(`/tasks/${id}`),
  create: (task: Omit<Task, 'id' | 'inserted_at'>) =>
    fetchApi<{ data: Task }>('/tasks', {
      method: 'POST',
      body: JSON.stringify({ task }),
    }),
  update: (id: number, task: Partial<Task>) =>
    fetchApi<{ data: Task }>(`/tasks/${id}`, {
      method: 'PUT',
      body: JSON.stringify({ task }),
    }),
  delete: (id: number) =>
    fetchApi<void>(`/tasks/${id}`, { method: 'DELETE' }),
};
```

## Component Patterns

```typescript
// components/features/TaskList.tsx
import { useState, useEffect } from 'react';
import { tasksApi, Task } from '@api/tasks';
import { TaskItem } from './TaskItem';

export function TaskList() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    tasksApi.list()
      .then(response => setTasks(response.data))
      .catch(err => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <ul>
      {tasks.map(task => (
        <TaskItem key={task.id} task={task} />
      ))}
    </ul>
  );
}
```

## Testing

```typescript
// __tests__/TaskList.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { TaskList } from '../components/features/TaskList';
import { tasksApi } from '../api/tasks';

jest.mock('../api/tasks');

describe('TaskList', () => {
  it('renders tasks from API', async () => {
    (tasksApi.list as jest.Mock).mockResolvedValue({
      data: [{ id: 1, title: 'Test Task', completed: false }]
    });

    render(<TaskList />);

    await waitFor(() => {
      expect(screen.getByText('Test Task')).toBeInTheDocument();
    });
  });
});
```
