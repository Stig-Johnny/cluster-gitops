#!/bin/bash
# add-all-to-argocd.sh
# This script interactively applies all ArgoCD Application manifests found in the repository that are NOT included in any app-of-apps Application.
# Usage: ./add-all-to-argocd.sh
#
# This script will search for all files ending with 'argocd.yaml' in the repository and prompt you for each one,
# but will skip those that are referenced in any app-of-apps Application manifest (argocd-app.yaml at the root of argocd/).
# Enter 'y' to apply the ArgoCD Application manifest, or 'n' to skip it.
#
# Example usage:
#   ./add-all-to-argocd.sh
#
# You must have 'kubectl' configured and access to your cluster.
#
# This is useful if you reorganize your repo or want to apply all ArgoCD Applications in one go, except those managed by app-of-apps.
#
# Note: The script will stop on the first error due to 'set -e'.
#
# To run this script, use:
#   bash add-all-to-argocd.sh
#
# If you want to run it directly (./add-all-to-argocd.sh), make it executable first:
#   chmod +x add-all-to-argocd.sh

set -e

# Find all app-of-apps Application manifests (typically argocd/argocd-app.yaml)
APPOFAPPS_FILES=$(find ./argocd -type f -name "*argocd-app.yaml" 2>/dev/null)

# Collect all referenced paths in app-of-apps
APPOFAPPS_PATHS=()
for appfile in $APPOFAPPS_FILES; do
  while read -r path; do
    cleanpath=$(echo "$path" | sed 's/^ *path: *//;s/["\'"'"' ]//g')
    [ -n "$cleanpath" ] && APPOFAPPS_PATHS+=("$cleanpath")
  done < <(grep '^ *path:' "$appfile")
done

# Find all argocd.yaml files in the repo
find . -type f -name "*argocd.yaml" | while IFS= read -r appfile; do
  # Check if this file is referenced in any app-of-apps by path
  managed=false
  appdir=$(dirname "$appfile" | sed 's|^./||')
  for refpath in "${APPOFAPPS_PATHS[@]}"; do
    if [[ "$appdir" == "$refpath" ]]; then
      managed=true
      break
    fi
  done
  if $managed; then
    echo "Skipping $appfile (managed by app-of-apps)"
    continue
  fi
  echo "Found $appfile. Apply this ArgoCD Application? (y/n)"
  read -r answer < /dev/tty
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Applying $appfile ..."
    kubectl apply -f "$appfile"
  else
    echo "Skipping $appfile."
  fi
done

echo "Script finished."
