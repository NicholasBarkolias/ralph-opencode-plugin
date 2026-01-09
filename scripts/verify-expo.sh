#!/bin/bash

# Expo/React Native verification script for Ralph
# Runs typecheck, lint, and tests

set -e

echo "🔍 Running Expo verification..."

echo "📝 Type checking..."
npm run typecheck

echo "🔎 Linting..."
npm run lint

echo "🧪 Running tests..."
npm test

echo "✅ Expo verification complete!"
