#!/bin/bash
set -e

echo "Verifying React..."

cd assets

echo "  -> Type checking..."
npm run typecheck

echo "  -> Linting..."
npm run lint

echo "  -> Running tests..."
npm test

echo "React verification passed!"
