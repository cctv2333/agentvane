#!/usr/bin/env bash
set -euo pipefail

# Enumerate every skill (SKILL.md) in the collection.
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
find skills -name SKILL.md -not -path '*/node_modules/*' | sed 's|^\./||' | sort
