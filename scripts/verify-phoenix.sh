#!/bin/bash
set -e

echo "Verifying Phoenix..."

echo "  -> Compiling..."
mix compile --warnings-as-errors

echo "  -> Checking format..."
mix format --check-formatted

echo "  -> Running Credo..."
mix credo --strict

echo "  -> Running tests..."
mix test

echo "Phoenix verification passed!"
