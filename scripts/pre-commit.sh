#!/usr/bin/env bash
set -euo pipefail

# AgentVane pre-commit gate: secrets + structure health.
# Call it from a git hook, or run manually before any commit.
#   bash scripts/pre-commit.sh
# Exit non-zero on any finding (blocking), so the commit is rejected.
#
# How to install as the repo's pre-commit hook (run once, or via link-hooks):
#   git config core.hooksPath .githooks 2>/dev/null || true
#   ln -sfn ../../scripts/pre-commit.sh .git/hooks/pre-commit
#   chmod +x scripts/pre-commit.sh

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

fail=0

# --- 1. secret scan ---
if command -v gitleaks >/dev/null 2>&1; then
  echo "[pre-commit] gitleaks detect..."
  if ! gitleaks detect --source . --redact --exit-code 1; then
    echo "[pre-commit] ✗ gitleaks found a secret (see above). Commit blocked." >&2
    fail=1
  fi
else
  echo "[pre-commit] ⚠ gitleaks not found; skipping secret scan (install gitleaks to enforce)." >&2
fi

# --- 2. structure / consistency ---
echo "[pre-commit] check-consistency..."
if ! node scripts/check-consistency.mjs --check; then
  echo "[pre-commit] ✗ structure/consistency failed (see above). Commit blocked." >&2
  fail=1
fi

# --- 3. list skills sanity ---
echo "[pre-commit] skills enumerated:"
bash scripts/list-skills.sh

if [ "$fail" -ne 0 ]; then
  echo "[pre-commit] BLOCKED." >&2
  exit 1
fi
echo "[pre-commit] OK."
