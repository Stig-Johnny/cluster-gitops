# Cluster Default Tooling (App of Apps)

This directory manages cluster-wide tools using the ArgoCD App of Apps pattern. Each tool is managed as a separate ArgoCD Application for scalability and maintainability.

## Structure
- `cluster-default-tooling-argocd.yaml`: The App of Apps manifest. Defines an ArgoCD Application for each tool.
- `nfs-csi-driver-argocd.yaml`: ArgoCD Application manifest for the NFS CSI driver.
- `dashboard-argocd.yaml`: ArgoCD Application manifest for the Kubernetes Dashboard.
- `dashboard/`: Contains kustomization for the Kubernetes Dashboard.

## App of Apps Pattern

This directory uses the ArgoCD App of Apps pattern:
- The parent Application (`cluster-default-tooling-argocd.yaml`) uses `directory.recurse: true` to discover all child Application manifests in this directory.
- Each tool (e.g., NFS CSI driver, Kubernetes Dashboard) is managed as a separate ArgoCD Application manifest (`*-argocd.yaml`).
- To add a new tool, simply add a new Application manifest in this directory.

This approach is scalable, secure, and easy to maintain.

## How to add a new tool
1. Create a directory for the tool (if needed).
2. Add a kustomization and manifests for the tool.
3. Create an ArgoCD Application manifest for the tool (e.g., `my-tool-argocd.yaml`) in this directory.
   - **You do NOT need to edit or reference the parent App of Apps manifest.**
   - ArgoCD will automatically discover and manage all `*-argocd.yaml` Application manifests in this directory.

## Why App of Apps?
- **Scalability:** Each tool is managed independently.
- **Security:** No cross-directory references; each Application is self-contained.
- **Maintainability:** Easy to add, remove, or update tools without affecting others.

## Usage
- To apply the App of Apps for the first time, run:
  ```sh
  kubectl apply -f cluster-default-tooling-argocd.yaml
  ```
- ArgoCD will automatically discover and manage all `*-argocd.yaml` Application manifests in this directory.

See the root `README.md` for more details on the overall GitOps workflow.
