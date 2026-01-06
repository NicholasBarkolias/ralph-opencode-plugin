#!/bin/bash

# Ralph Wiggum Loop Runner for OpenCode
# Usage: ./scripts/ralph.sh "task description" [max-iterations] [stack]

set -e

TASK="${1:?Task description required}"
MAX_ITERATIONS="${2:-25}"
STACK="${3:-full}"
COMPLETION_PROMISE="RALPH_COMPLETE"

echo "Starting Ralph Loop"
echo "   Task: $TASK"
echo "   Max Iterations: $MAX_ITERATIONS"
echo "   Stack: $STACK"
echo ""

ITERATION=0

while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Iteration $ITERATION / $MAX_ITERATIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Run opencode with the ralph command
    OUTPUT=$(opencode run ralph --task "$TASK" --stack "$STACK" 2>&1) || true
    
    echo "$OUTPUT"
    
    # Check for completion
    if echo "$OUTPUT" | grep -q "$COMPLETION_PROMISE"; then
        echo ""
        echo "Ralph completed successfully after $ITERATION iterations!"
        exit 0
    fi
    
    # Check for blocked tasks
    if echo "$OUTPUT" | grep -q "\[BLOCKED\]"; then
        echo ""
        echo "Warning: Some tasks are blocked. Check plan.md for details."
    fi
    
    # Small delay to prevent rate limiting
    sleep 2
done

echo ""
echo "Max iterations ($MAX_ITERATIONS) reached."
echo "   Check plan.md for remaining tasks."
exit 1
