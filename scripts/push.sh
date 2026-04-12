#!/bin/bash
# Quick git add, commit, and push
# Usage: ./scripts/push.sh "Your commit message"

MESSAGE=${1:-"Update project files"}
git add .
git commit -m "$MESSAGE"
git push
echo "✅ Pushed: $MESSAGE"O
