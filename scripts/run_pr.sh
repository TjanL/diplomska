#!/bin/bash

BASE_BRANCH="main"
NEW_BRANCH="feature-branch-$(date +%Y%m%d%H%M%S)"

git fetch origin

git checkout $BASE_BRANCH
git pull origin $BASE_BRANCH

git checkout -b $NEW_BRANCH

if [ -d "app" ]; then
  echo "$(date +%Y%m%d%H%M%S)" > app/testfile.txt
  git add app/testfile.txt
fi

if [ -d "server" ]; then
  echo "$(date +%Y%m%d%H%M%S)" > server/testfile.txt
  git add server/testfile.txt
fi
git commit -m "Add test file"

git push origin $NEW_BRANCH

gh pr create --base $BASE_BRANCH --head $NEW_BRANCH --title $NEW_BRANCH --body ""

PR_URL=$(gh pr view --json url -q .url)
PR_NUMBER=$(gh pr view --json number -q .number)

echo "Pull request created successfully: $PR_URL"
