#!/usr/bin/env bash
# Full reset for the Ruby Monkey Patching demos.
# Removes all SQLite database files and restarts the Jupyter container
# (which clears all in-session kernel state).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Ruby Monkey Patching — Full Reset ==="

# ── Remove SQLite database files ──────────────────────────────────────────────
echo ""
echo "Removing database files..."
count=0
while IFS= read -r -d '' f; do
  echo "  rm ${f#"$SCRIPT_DIR"/}"
  rm "$f"
  ((count++)) || true
done < <(find "$SCRIPT_DIR" -name "*.db" -type f -print0)

if [ "$count" -eq 0 ]; then
  echo "  (none found)"
else
  echo "  $count file(s) removed"
fi

# ── Restart Jupyter container (clears all kernel state) ───────────────────────
echo ""
if docker compose -f "$SCRIPT_DIR/docker-compose.yml" ps --quiet lab 2>/dev/null | grep -q .; then
  echo "Restarting Jupyter container..."
  docker compose -f "$SCRIPT_DIR/docker-compose.yml" restart lab
  echo "  done — refresh http://localhost:8888 and re-select the Ruby kernel in each notebook"
else
  echo "Jupyter is not running — start with: docker compose up"
fi

echo ""
echo "Reset complete."
