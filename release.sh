#!/bin/bash

set -e

# Ensure a version number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION=$1

# Validate the version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
  echo "Version must be in the format x.x.x or x.x.x-tag (e.g., 1.0.0 or 1.0.0-beta)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PODSPEC_PATH="$SCRIPT_DIR/DaroObjCBridge.podspec"

# 현재 브랜치 감지 (정보 표시용)
CURRENT_BRANCH=$(git branch --show-current)
echo $'\e[34m=== DaroObjCBridge 서브모듈 릴리스 시작 ===\e[0m'
echo "서브모듈 현재 브랜치: $CURRENT_BRANCH"
echo "릴리스 버전: $VERSION"
echo $'\e[34m=============================\e[0m'
echo ""

# Update version in podspec file
sed -i '' "s/spec\.version[[:space:]]*= '[^']*'/spec.version      = '$VERSION'/" "$PODSPEC_PATH"

# Commit and push the changes (skip if nothing to commit)
if git diff --quiet && git diff --cached --quiet; then
  echo "⚠️  No changes to commit, skipping"
else
  git add .
  if git commit -m "Bump version to $VERSION" 2>/dev/null; then
    echo "✅ Changes committed"
  else
    echo "⚠️  Nothing to commit or commit failed, continuing..."
  fi

  if git push origin $CURRENT_BRANCH 2>/dev/null; then
    echo "✅ Changes pushed to $CURRENT_BRANCH"
  else
    echo "⚠️  Push failed or nothing to push, continuing..."
  fi
fi

# Create and push tag (skip if already exists)
if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "⚠️  Tag $VERSION already exists locally, skipping tag creation"
else
  git tag $VERSION
  echo "✅ Tag $VERSION created"
fi

if git ls-remote --tags origin | grep -q "refs/tags/$VERSION\$"; then
  echo "⚠️  Tag $VERSION already exists on remote, skipping tag push"
else
  git push origin $VERSION
  echo "✅ Tag $VERSION pushed to remote"
fi

# Check if DaroObjCBridge.xcframework.zip exists
if [ ! -f "$SCRIPT_DIR/build/DaroObjCBridge.xcframework.zip" ]; then
  echo "❌ $SCRIPT_DIR/build/DaroObjCBridge.xcframework.zip file not found"
  exit 1
fi

# Create a release using GitHub CLI (skip if already exists)
if gh release view $VERSION >/dev/null 2>&1; then
  echo "⚠️  GitHub release $VERSION already exists, skipping creation"
else
  gh release create $VERSION "$SCRIPT_DIR/build/DaroObjCBridge.xcframework.zip" --title "Release $VERSION" --notes "Release version $VERSION"
  echo "✅ GitHub release $VERSION created"
fi

git pull origin $CURRENT_BRANCH 2>/dev/null || echo "⚠️  Git pull failed or nothing to pull"

# Push the podspec to the trunk
echo "📦 Pushing podspec to CocoaPods trunk..."
pod trunk push "$PODSPEC_PATH" --allow-warnings --verbose
