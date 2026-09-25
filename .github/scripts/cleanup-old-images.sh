#!/usr/bin/env bash
set -euo pipefail

TARGET_PACKAGE="${1:-ihp-oci}"
KEEP_TAG="${2:-latest}"

echo "Cleaning old versions from $TARGET_PACKAGE..."
echo "Keeping tag: $KEEP_TAG"

# Sanity: verify KEEP_TAG actually exists before proceeding
EXISTING_TAGS=$(gh api --paginate "/user/packages/container/$TARGET_PACKAGE/versions" \
  | jq -r '.[] | select((.metadata.container.tags // []) | index("'"$KEEP_TAG"'")) | .metadata.container.tags[]' \
  | head -1)

if [ -z "$EXISTING_TAGS" ]; then
  echo "WARNING: No version found with tag '$KEEP_TAG'. Skipping cleanup to avoid breaking $TARGET_PACKAGE."
  echo "This may indicate $TARGET_PACKAGE:$KEEP_TAG doesn't exist yet (first build)."
  exit 0
fi

echo "Confirmed: $TARGET_PACKAGE:$KEEP_TAG exists. Proceeding with cleanup."

gh api --paginate "/user/packages/container/$TARGET_PACKAGE/versions" \
  | jq -r ".[] | select((.metadata.container.tags // []) | map(. == \"$KEEP_TAG\") | any | not) | .id" \
  | while read -r id; do
      [ -z "$id" ] && continue
      echo "Deleting version: $id"
      gh api --method DELETE "/user/packages/container/$TARGET_PACKAGE/versions/$id" || {
        echo "::warning::Failed to delete version $id"
      }
    done

echo "Cleanup complete — only $TARGET_PACKAGE:$KEEP_TAG remains."
