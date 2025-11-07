#!/bin/bash

set -e

# Ensure a version number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <version> [mode]"
  echo "  version: Version number (e.g., 1.0.0)"
  echo "  mode: Optional - 'cocoapods' to only deploy to CocoaPods"
  exit 1
fi

VERSION=$1
MODE="${2:-full}"

# Validate the version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
  echo "Version must be in the format x.x.x or x.x.x-tag (e.g., 1.0.0 or 1.0.0-beta)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PODSPEC_PATH="$SCRIPT_DIR/DaroObjCBridge.podspec"
STATE_FILE="$SCRIPT_DIR/.release-state-$VERSION"

# 현재 브랜치 감지 (정보 표시용)
CURRENT_BRANCH=$(git branch --show-current)
echo $'\e[34m=== DaroObjCBridge 서브모듈 릴리스 시작 ===\e[0m'
echo "서브모듈 현재 브랜치: $CURRENT_BRANCH"
echo "릴리스 버전: $VERSION"
echo "모드: $MODE"
echo $'\e[34m=============================\e[0m'
echo ""

# Function to mark step as completed
mark_step_completed() {
  echo "$1" >> "$STATE_FILE"
}

# Function to check if step is completed
is_step_completed() {
  [ -f "$STATE_FILE" ] && grep -q "^$1$" "$STATE_FILE"
}

# CocoaPods only mode
if [ "$MODE" == "cocoapods" ]; then
  echo "🚀 CocoaPods 전용 배포 모드"
  echo "📦 Pushing podspec to CocoaPods trunk..."
  if pod trunk push "$PODSPEC_PATH" --allow-warnings --verbose; then
    echo "✅ CocoaPods deployment successful!"
    mark_step_completed "COCOAPODS_DEPLOYED"
    rm -f "$STATE_FILE"
    exit 0
  else
    echo "❌ CocoaPods deployment failed"
    exit 1
  fi
fi

echo "🚀 전체 릴리스 모드"

# Update version in podspec file
if is_step_completed "PODSPEC_UPDATED"; then
  echo "⚠️  [1/5] Podspec already updated, skipping"
else
  echo "🔄 [1/5] Updating podspec version..."
  sed -i '' "s/spec\.version[[:space:]]*= '[^']*'/spec.version      = '$VERSION'/" "$PODSPEC_PATH"
  mark_step_completed "PODSPEC_UPDATED"
  echo "✅ [1/5] Podspec version updated"
fi

# Commit and push the changes
if is_step_completed "GIT_COMMITTED"; then
  echo "⚠️  [2/5] Changes already committed, skipping"
else
  echo "🔄 [2/5] Committing changes..."
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
  mark_step_completed "GIT_COMMITTED"
  echo "✅ [2/5] Git commit step completed"
fi

# Create and push tag
if is_step_completed "TAG_CREATED"; then
  echo "⚠️  [3/5] Tag already created and pushed, skipping"
else
  echo "🔄 [3/5] Creating and pushing tag..."
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
  mark_step_completed "TAG_CREATED"
  echo "✅ [3/5] Tag creation step completed"
fi

# Check if DaroObjCBridge.xcframework.zip exists
if [ ! -f "$SCRIPT_DIR/build/DaroObjCBridge.xcframework.zip" ]; then
  echo "❌ $SCRIPT_DIR/build/DaroObjCBridge.xcframework.zip file not found"
  exit 1
fi

# Create GitHub release
if is_step_completed "GITHUB_RELEASE"; then
  echo "⚠️  [4/5] GitHub release already created, skipping"
else
  echo "🔄 [4/5] Creating GitHub release..."
  if gh release view $VERSION >/dev/null 2>&1; then
    echo "⚠️  GitHub release $VERSION already exists, skipping creation"
  else
    # Create release first without file upload
    echo "📦 Creating release..."
    gh release create $VERSION --title "Release $VERSION" --notes "Release version $VERSION"
    echo "✅ GitHub release $VERSION created"

    # Upload file separately for better error handling
    echo "📤 Uploading XCFramework..."
    if gh release upload $VERSION "$SCRIPT_DIR/build/DaroObjCBridge.xcframework.zip" --clobber; then
      echo "✅ XCFramework uploaded successfully"
    else
      echo "❌ Failed to upload XCFramework"
      echo "💡 You can retry upload with: gh release upload $VERSION build/DaroObjCBridge.xcframework.zip --clobber"
      exit 1
    fi
  fi
  mark_step_completed "GITHUB_RELEASE"
  echo "✅ [4/5] GitHub release step completed"
fi

git pull origin $CURRENT_BRANCH 2>/dev/null || echo "⚠️  Git pull failed or nothing to pull"

# Push to CocoaPods
if is_step_completed "COCOAPODS_DEPLOYED"; then
  echo "⚠️  [5/5] CocoaPods already deployed, skipping"
  echo "🎉 All steps completed!"
  rm -f "$STATE_FILE"
else
  echo "🔄 [5/5] Pushing podspec to CocoaPods trunk..."
  if pod trunk push "$PODSPEC_PATH" --allow-warnings --verbose; then
    mark_step_completed "COCOAPODS_DEPLOYED"
    echo "✅ [5/5] CocoaPods deployment completed"
    echo "🎉 All steps completed!"
    rm -f "$STATE_FILE"
  else
    echo "❌ CocoaPods deployment failed"
    echo "💡 To retry only CocoaPods deployment, run: ./release.sh $VERSION cocoapods"
    exit 1
  fi
fi
