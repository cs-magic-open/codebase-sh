#!/bin/bash

# Ensure you're in the root of your Git repository
# e.g. clean node_modules, which are accidentally added
git filter-branch --force --index-filter \
  "git rm -r --cached --ignore-unmatch node_modules" \
  --prune-empty --tag-name-filter cat -- --all

# Force push to remote repository (be careful with this!)
# git push origin --force --all

# Clean up the old references
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

# Cleanup and reclaim space
git reflog expire --expire=now --all
git gc --prune=now --aggressive
