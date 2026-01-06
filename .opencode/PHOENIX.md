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
