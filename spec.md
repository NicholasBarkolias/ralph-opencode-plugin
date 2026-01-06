# Building a Ralph Wiggum Plugin for OpenCode (Elixir/Phoenix/React)

Let me create a comprehensive plugin tailored for Phoenix + React development.

## Project Structure

```
ralph-opencode/
├── plugin.json
├── README.md
├── commands/
│   ├── ralph-loop.md
│   ├── ralph-plan.md
│   ├── ralph-phoenix.md
│   ├── ralph-react.md
│   └── ralph-full-stack.md
├── agents/
│   ├── AGENTS.md
│   ├── PHOENIX.md
│   └── REACT.md
├── templates/
│   ├── plan-template.md
│   └── task-template.md
└── scripts/
    ├── ralph.sh
    ├── verify-phoenix.sh
    └── verify-react.sh
```

## Core Plugin Configuration

**plugin.json:**
```json
{
  "name": "ralph-opencode",
  "version": "1.0.0",
  "description": "Ralph Wiggum autonomous loop for Phoenix + React projects",
  "author": "Your Name",
  "commands": [
    "./commands/ralph-loop.md",
    "./commands/ralph-plan.md",
    "./commands/ralph-phoenix.md",
    "./commands/ralph-react.md",
    "./commands/ralph-full-stack.md"
  ],
  "agents": [
    "./agents/AGENTS.md",
    "./agents/PHOENIX.md",
    "./agents/REACT.md"
  ],
  "config": {
    "defaultMaxIterations": 25,
    "defaultModel": "opencode/claude-opus-4-5",
    "completionPromise": "RALPH_COMPLETE",
    "verifyCommands": {
      "phoenix": "mix compile --warnings-as-errors && mix test",
      "react": "cd assets && npm run typecheck && npm test",
      "fullStack": "mix compile --warnings-as-errors && mix test && cd assets && npm run typecheck && npm test"
    }
  }
}
```

## Agent Knowledge Files

**agents/AGENTS.md:**
```markdown
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
```

**agents/PHOENIX.md:**
```markdown
# Phoenix Development Guidelines

## Project Structure

```
lib/
├── app_name/           # Domain/business logic
│   ├── accounts/       # Context modules
│   │   ├── user.ex     # Schema
│   │   └── accounts.ex # Context functions
│   └── repo.ex
├── app_name_web/       # Web layer
│   ├── controllers/
│   ├── components/
│   ├── live/           # LiveView (if used)
│   └── router.ex
test/
├── app_name/
└── app_name_web/
```

## Patterns to Follow

### Context Pattern
```elixir
# Always use contexts for business logic
defmodule AppName.Tasks do
  alias AppName.Repo
  alias AppName.Tasks.Task

  def list_tasks, do: Repo.all(Task)
  def get_task!(id), do: Repo.get!(Task, id)
  def create_task(attrs), do: %Task{} |> Task.changeset(attrs) |> Repo.insert()
end
```

### API Controllers (for React frontend)
```elixir
defmodule AppNameWeb.Api.TaskController do
  use AppNameWeb, :controller
  alias AppName.Tasks

  def index(conn, _params) do
    tasks = Tasks.list_tasks()
    json(conn, %{data: tasks})
  end
end
```

### Router Setup for React SPA
```elixir
# In router.ex
scope "/api", AppNameWeb.Api, as: :api do
  pipe_through :api
  resources "/tasks", TaskController
end

# Catch-all for React SPA
scope "/app", AppNameWeb do
  pipe_through :browser
  get "/*path", PageController, :app
end
```

## Common Commands

```bash
# Generate context with schema
mix phx.gen.context Tasks Task tasks title:string completed:boolean

# Generate JSON API
mix phx.gen.json Tasks Task tasks title:string completed:boolean --web Api

# Run migrations
mix ecto.migrate

# Interactive shell
iex -S mix phx.server
```

## Testing Patterns

```elixir
defmodule AppName.TasksTest do
  use AppName.DataCase

  alias AppName.Tasks

  describe "tasks" do
    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end
  end
end
```
```

**agents/REACT.md:**
```markdown
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
```

## Command Files

**commands/ralph-loop.md:**
```markdown
---
name: ralph
description: Start an autonomous Ralph Wiggum development loop
args:
  - name: task
    description: The task or feature to implement
    required: true
  - name: max-iterations
    description: Maximum iterations before stopping
    default: "25"
  - name: stack
    description: Which stack to focus on (phoenix|react|full)
    default: "full"
---

# Ralph Wiggum Autonomous Loop

You are Ralph, an autonomous coding agent working on a Phoenix + React project.

## Your Mission

{{task}}

## Instructions

### 1. Orientation (First Iteration Only)
- Read `plan.md` if it exists
- Read `AGENTS.md`, `PHOENIX.md`, `REACT.md` for project guidelines
- Run `git status` and `git log --oneline -10` to understand current state
- If no `plan.md` exists, create one with a task breakdown

### 2. Every Iteration

#### 2a. Select ONE Task
- Open `plan.md`
- Find the first unchecked `[ ]` task
- If all tasks are complete, output: `RALPH_COMPLETE`

#### 2b. Implement Task
- Make the smallest possible change
- Follow patterns from agent files
- For Phoenix: use contexts, follow conventions
- For React: use TypeScript strictly, follow component patterns

#### 2c. Verify Changes

For {{stack}} stack, run verification:

**Phoenix:**
```bash
mix compile --warnings-as-errors
mix format --check-formatted
mix test
```

**React:**
```bash
cd assets && npm run typecheck
cd assets && npm test
```

**Full Stack:**
```bash
mix compile --warnings-as-errors && mix test
cd assets && npm run typecheck && npm test
```

If verification fails:
- Read error messages carefully
- Fix the issue
- Re-run verification
- Do NOT proceed until verification passes

#### 2d. Commit Changes
```bash
git add -A
git commit -m "[area] description of change"
```

NEVER run `git push`.

#### 2e. Update plan.md
- Mark completed task as `[x]`
- Add any new discovered tasks as `[ ]`
- Add notes about implementation decisions

#### 2f. Update AGENTS.md (If Needed)
If you learned something critical (gotcha, pattern, configuration), add it to the "Critical Learnings" section.

### 3. Completion

When ALL tasks in plan.md are marked `[x]`:

Output exactly: `RALPH_COMPLETE`

## Constraints

- ONE task per iteration
- ALL verification must pass before commit
- NEVER skip verification
- NEVER push to remote
- NEVER modify files outside project scope
- If stuck for 3+ attempts on same task, add `[BLOCKED]` prefix and move to next task
```

**commands/ralph-plan.md:**
```markdown
---
name: ralph-plan
description: Create a detailed plan.md for Ralph to execute
args:
  - name: feature
    description: The feature or task to plan
    required: true
  - name: stack
    description: Which stack (phoenix|react|full)
    default: "full"
---

# Create Ralph Execution Plan

## Feature Request

{{feature}}

## Instructions

Analyze the feature request and create a detailed `plan.md` file.

### 1. Understand the Scope
- What Phoenix changes are needed? (contexts, schemas, migrations, controllers)
- What React changes are needed? (components, hooks, API calls, types)
- What tests are needed?

### 2. Create plan.md

Use this template:

```markdown
# Plan: {{feature}}

## Overview
Brief description of what we're building.

## Stack: {{stack}}

## Tasks

### Phoenix Backend
- [ ] Create migration for X table
- [ ] Create X schema with changeset
- [ ] Create X context with CRUD functions
- [ ] Add API routes to router.ex
- [ ] Create XController with index/show/create/update/delete
- [ ] Write context tests
- [ ] Write controller tests

### React Frontend
- [ ] Create TypeScript types for X
- [ ] Create API client functions for X
- [ ] Create XList component
- [ ] Create XItem component
- [ ] Create XForm component (create/edit)
- [ ] Add routing for X pages
- [ ] Write component tests

### Integration
- [ ] Verify full flow works end-to-end
- [ ] Add error handling
- [ ] Add loading states

## Notes
- Any special considerations
- Dependencies between tasks
- Potential blockers

## Progress Log
<!-- Ralph will update this section -->
```

### 3. Guidelines for Tasks

- Each task should be completable in ONE iteration
- Tasks should be ordered by dependency (migrations before schemas, schemas before contexts)
- Include verification criteria in task if complex
- Group related tasks but keep them atomic

### 4. Output

Save the plan to `plan.md` in the project root.

Then output: `PLAN_CREATED`
```

**commands/ralph-phoenix.md:**
```markdown
---
name: ralph-phoenix
description: Phoenix-focused Ralph loop
args:
  - name: task
    description: The Phoenix task to implement
    required: true
  - name: max-iterations
    description: Maximum iterations
    default: "20"
---

# Phoenix-Focused Ralph Loop

You are Ralph, focused exclusively on Elixir/Phoenix development.

## Mission
{{task}}

## Phoenix-Specific Guidelines

### Always Follow These Patterns

1. **Contexts Over Schemas**
   - Never call Repo directly from controllers
   - All business logic goes in context modules

2. **Changesets for All Data**
   ```elixir
   def changeset(struct, attrs) do
     struct
     |> cast(attrs, [:field1, :field2])
     |> validate_required([:field1])
   end
   ```

3. **API Controllers Return JSON**
   ```elixir
   def index(conn, _params) do
     items = Context.list_items()
     json(conn, %{data: items})
   end

   def show(conn, %{"id" => id}) do
     item = Context.get_item!(id)
     json(conn, %{data: item})
   end
   ```

4. **Error Handling**
   ```elixir
   case Context.create_item(attrs) do
     {:ok, item} -> 
       conn
       |> put_status(:created)
       |> json(%{data: item})
     {:error, changeset} ->
       conn
       |> put_status(:unprocessable_entity)
       |> json(%{errors: format_errors(changeset)})
   end
   ```

### Verification (Every Iteration)

```bash
mix compile --warnings-as-errors
mix format --check-formatted
mix credo --strict
mix test
```

### Commit Format
`[phoenix] description`
`[ecto] description` (for migrations/schemas)
`[api] description` (for controllers/routes)

## Loop Instructions

1. Read plan.md, select ONE Phoenix task
2. Implement following patterns above
3. Run ALL verification commands
4. Commit with proper format
5. Update plan.md
6. If all Phoenix tasks done: `RALPH_COMPLETE`
```

**commands/ralph-react.md:**
```markdown
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
```

**commands/ralph-full-stack.md:**
```markdown
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
```

## Shell Scripts

**scripts/ralph.sh:**
```bash
#!/bin/bash

# Ralph Wiggum Loop Runner for OpenCode
# Usage: ./scripts/ralph.sh "task description" [max-iterations] [stack]

set -e

TASK="${1:?Task description required}"
MAX_ITERATIONS="${2:-25}"
STACK="${3:-full}"
COMPLETION_PROMISE="RALPH_COMPLETE"

echo "🧠 Starting Ralph Loop"
echo "   Task: $TASK"
echo "   Max Iterations: $MAX_ITERATIONS"
echo "   Stack: $STACK"
echo ""

ITERATION=0

while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 Iteration $ITERATION / $MAX_ITERATIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Run opencode with the ralph command
    OUTPUT=$(opencode run ralph --task "$TASK" --stack "$STACK" 2>&1) || true
    
    echo "$OUTPUT"
    
    # Check for completion
    if echo "$OUTPUT" | grep -q "$COMPLETION_PROMISE"; then
        echo ""
        echo "✅ Ralph completed successfully after $ITERATION iterations!"
        exit 0
    fi
    
    # Check for blocked tasks
    if echo "$OUTPUT" | grep -q "\[BLOCKED\]"; then
        echo ""
        echo "⚠️  Some tasks are blocked. Check plan.md for details."
    fi
    
    # Small delay to prevent rate limiting
    sleep 2
done

echo ""
echo "⏰ Max iterations ($MAX_ITERATIONS) reached."
echo "   Check plan.md for remaining tasks."
exit 1
```

**scripts/verify-phoenix.sh:**
```bash
#!/bin/bash
set -e

echo "🔍 Verifying Phoenix..."

echo "  → Compiling..."
mix compile --warnings-as-errors

echo "  → Checking format..."
mix format --check-formatted

echo "  → Running Credo..."
mix credo --strict

echo "  → Running tests..."
mix test

echo "✅ Phoenix verification passed!"
```

**scripts/verify-react.sh:**
```bash
#!/bin/bash
set -e

echo "🔍 Verifying React..."

cd assets

echo "  → Type checking..."
npm run typecheck

echo "  → Linting..."
npm run lint

echo "  → Running tests..."
npm test

echo "✅ React verification passed!"
```

## Template Files

**templates/plan-template.md:**
```markdown
# Plan: [FEATURE NAME]

## Overview
[Brief description of the feature]

## Stack Focus
- [ ] Phoenix Backend
- [ ] React Frontend
- [ ] Full Stack

## Tasks

### Database & Schema
- [ ] Create migration for [table]
- [ ] Create [Model] schema with changeset

### Phoenix Context
- [ ] Create [Context] module
- [ ] Implement list_[items]/0
- [ ] Implement get_[item]!/1
- [ ] Implement create_[item]/1
- [ ] Implement update_[item]/2
- [ ] Implement delete_[item]/1

### API Layer
- [ ] Add routes to router.ex
- [ ] Create [Resource]Controller
- [ ] Implement index action
- [ ] Implement show action
- [ ] Implement create action
- [ ] Implement update action
- [ ] Implement delete action

### Backend Tests
- [ ] Write context tests
- [ ] Write controller tests

### React Types & API
- [ ] Create TypeScript types for [Model]
- [ ] Create API client for [resource]

### React Components
- [ ] Create [Model]List component
- [ ] Create [Model]Item component
- [ ] Create [Model]Form component
- [ ] Add routing

### Frontend Tests
- [ ] Write component tests
- [ ] Write integration tests

## Dependencies
[Note any task dependencies]

## Notes
[Any special considerations]

## Progress Log
<!-- Updated by Ralph after each iteration -->
```

## Usage Examples

### Basic Usage

```bash
# Create a plan first
opencode run ralph-plan --feature "User task management with CRUD operations"

# Then run the loop
opencode run ralph --task "Implement the plan in plan.md" --max-iterations 30

# Or use the shell script
./scripts/ralph.sh "Implement user task management" 30 full
```

### Phoenix-Only Development

```bash
opencode run ralph-phoenix --task "Add authentication using phx.gen.auth" --max-iterations 15
```

### React-Only Development

```bash
opencode run ralph-react --task "Build dashboard components for task analytics" --max-iterations 20
```

### Full Feature Development

```bash
# Step 1: Plan
opencode run ralph-plan --feature "Real-time task updates using Phoenix Channels and React hooks" --stack full

# Step 2: Execute
opencode run ralph-full --feature "Implement real-time task updates per plan.md" --max-iterations 50
```

## Installation

1. Clone or copy this plugin to your OpenCode plugins directory
2. Make scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```
3. Register the plugin with OpenCode:
   ```bash
   opencode plugins add ./ralph-opencode
   ```

## Cost Considerations

As noted in the research, autonomous loops can be expensive:

| Iterations | Estimated Cost |
|------------|----------------|
| 10         | $10-20         |
| 25         | $25-50         |
| 50         | $50-100+       |

Start with lower iteration limits until you understand the consumption pattern for your specific project.

---

This plugin provides a complete framework for Ralph-style autonomous development on Phoenix + React projects. The key is the **feedback loop**: failures teach the agent, and the plan.md acts as persistent state across iterations.
