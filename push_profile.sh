#!/usr/bin/env bash
# Create + push the ariandesu profile repo using a fine-grained PAT with repo-creation rights.
# Usage: ./push_profile.sh <NEW_TOKEN>
set -euo pipefail

TOKEN="${1:?Usage: ./push_profile.sh <TOKEN>}"
PROFILE_DIR="$HOME/Development/ariandesu-profile"

echo "==> Verifying token..."
LOGIN=$(curl -s --max-time 8 -H "Authorization: Bearer $TOKEN" https://api.github.com/user | grep -oP '"login":\s*"\K[^"]+' || true)
if [[ "$LOGIN" != "ariandesu" ]]; then
  echo "ERROR: Token does not authenticate as ariandesu (got: '${LOGIN:-none}'). Aborting."
  exit 1
fi
echo "    Authenticated as: $LOGIN"

echo "==> Checking if repo already exists..."
EXISTS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 -H "Authorization: Bearer $TOKEN" https://api.github.com/repos/ariandesu/ariandesu)
if [[ "$EXISTS" == "404" ]]; then
  echo "==> Creating repo ariandesu/ariandesu (public)..."
  RESP=$(curl -s --max-time 10 -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    https://api.github.com/user/repos \
    -d '{"name":"ariandesu","description":"Profile README — Mahir Faisal (MHR3D): AI researcher, autonomous agent builder, creator of ShareFlow","homepage":"https://shareflow.mhr3d.online","public":true,"has_issues":false,"has_projects":false,"has_wiki":false}')
  echo "$RESP" | grep -q '"full_name"' && echo "    Repo created ✓" || { echo "    FAILED: $RESP"; exit 1; }
else
  echo "    Repo already exists (HTTP $EXISTS)"
fi

echo "==> Pushing..."
cd "$PROFILE_DIR"
git remote remove origin 2>/dev/null || true
git remote add origin "https://ariandesu:${TOKEN}@github.com/ariandesu/ariandesu.git"
git push -u origin main
git remote set-url origin "https://github.com/ariandesu/ariandesu.git"  # scrub token from remote
echo ""
echo "✅ DONE! Profile live at: https://github.com/ariandesu"
