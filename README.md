# Ralph Wiggum Plugin for OpenCode

An autonomous development loop plugin for Phoenix + React projects.

## Installation

### Option 1: Copy to your project

Copy the `.opencode/` directory to your Phoenix + React project:

```bash
cp -r .opencode/ /path/to/your/project/
```

### Option 2: Global installation

Copy to your global OpenCode config:

```bash
cp -r .opencode/command/* ~/.config/opencode/command/
```

## Available Commands

Once installed, the following commands are available in OpenCode:

| Command | Description |
|---------|-------------|
| `/ralph <task>` | Start an autonomous development loop for the given task |
| `/ralph-plan <feature>` | Create a detailed plan.md for Ralph to execute |
| `/ralph-phoenix <task>` | Phoenix-focused development loop |
| `/ralph-react <task>` | React/TypeScript-focused development loop |
| `/ralph-full <feature>` | Full-stack feature implementation loop |

## Usage

### Basic Usage

1. First, create a plan:
   ```
   /ralph-plan Add user authentication with JWT
   ```

2. Then run the loop:
   ```
   /ralph Implement the plan in plan.md
   ```

### Phoenix-Only Development

```
/ralph-phoenix Add authentication using phx.gen.auth
```

### React-Only Development

```
/ralph-react Build dashboard components for task analytics
```

### Full Feature Development

```
/ralph-full Real-time task updates using Phoenix Channels and React hooks
```

## How It Works

### The Ralph Loop

1. **Orientation**: Ralph reads existing plan.md and agent guidelines
2. **Task Selection**: Picks the first unchecked `[ ]` task
3. **Implementation**: Makes the smallest possible change
4. **Verification**: Runs tests and type checks
5. **Commit**: Creates a git commit with proper format
6. **Update Plan**: Marks task complete, adds new discoveries
7. **Repeat**: Until all tasks are done or max iterations reached

### Completion Signal

When all tasks are complete, Ralph outputs: `RALPH_COMPLETE`

### Blocked Tasks

If stuck for 3+ attempts, Ralph adds `[BLOCKED]` prefix and moves on.

## Project Structure

```
ralph-plugin/
├── .opencode/
│   ├── command/           # OpenCode custom commands
│   │   ├── ralph.md       # Main autonomous loop
│   │   ├── ralph-plan.md  # Planning command
│   │   ├── ralph-phoenix.md
│   │   ├── ralph-react.md
│   │   └── ralph-full.md
│   ├── AGENTS.md          # Core guidelines
│   ├── PHOENIX.md         # Phoenix patterns
│   └── REACT.md           # React patterns
├── agents/                # Reference copies
├── commands/              # Original spec format
├── scripts/               # Shell scripts for CI/automation
│   ├── ralph.sh           # Loop runner script
│   ├── verify-phoenix.sh
│   └── verify-react.sh
├── templates/
│   └── plan-template.md
└── plugin.json            # Plugin metadata
```

## Verification Commands

### Phoenix
```bash
mix compile --warnings-as-errors
mix format --check-formatted
mix credo --strict
mix test
```

### React/TypeScript
```bash
cd assets
npm run typecheck
npm run lint
npm test
```

## Commit Convention

Format: `[area] brief description`

- `[phoenix]` - Phoenix/Elixir code
- `[ecto]` - Migrations/schemas
- `[api]` - Controllers/routes
- `[react]` - React components
- `[typescript]` - Type definitions
- `[ui]` - UI components

## Shell Script Usage

For automation or CI environments:

```bash
./scripts/ralph.sh "Implement user task management" 30 full
```

Arguments:
1. Task description (required)
2. Max iterations (default: 25)
3. Stack: phoenix|react|full (default: full)

## Cost Considerations

Autonomous loops can be expensive:

| Iterations | Estimated Cost |
|------------|----------------|
| 10         | $10-20         |
| 25         | $25-50         |
| 50         | $50-100+       |

Start with lower iteration limits until you understand the consumption pattern.

## License

MIT
