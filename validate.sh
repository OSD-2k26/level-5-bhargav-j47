#!/bin/bash
set -e

EXPECTED="omega_key"

# 1. artifact must exist in main
git checkout main >/dev/null 2>&1

[ -f artifact.txt ] || {
  echo "❌ artifact.txt missing in main"
  exit 1
}

CONTENT=$(cat artifact.txt | tr '[:upper:]' '[:lower:]')
[ "$CONTENT" = "$EXPECTED" ] || {
  echo "❌ artifact content incorrect"
  exit 1
}

# 2. artifact must NOT exist in alpha or beta
for BR in alpha beta; do
  if git show "$BR:artifact.txt" >/dev/null 2>&1; then
    echo "❌ artifact.txt still exists in $BR"
    exit 1
  fi
done

# 3. artifact MUST exist in gamma history
git show gamma:artifact.txt >/dev/null 2>&1 || {
  echo "❌ artifact never passed through gamma"
  exit 1
}

# 4. no merge commits allowed
if git log --oneline --merges | grep -q .; then
  echo "❌ Merge commits detected — maze poisoned"
  exit 1
fi

# 5. must have at least 4 branches
BRANCH_COUNT=$(git branch | wc -l)
[ "$BRANCH_COUNT" -ge 4 ] || {
  echo "❌ Not enough branches created"
  exit 1
}

echo "✅ LEVEL 5 PASSED"
