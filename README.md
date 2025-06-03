# Cluster GitOps

This repository manages cluster-wide tools and operators for your Kubernetes cluster using GitOps principles. It is designed to be the central place for deploying and managing shared infrastructure components that all other application GitOps repositories depend on.

## Structure

- `storage/nfs-csi-driver/` — NFS CSI driver manifests, StorageClass, and example PVC for NFS-based persistent storage.
- `argocd/` — ArgoCD manifests and configuration, managed via GitOps. This allows you to upgrade or configure ArgoCD by editing files in this repository and letting ArgoCD sync itself. Safe to use even if ArgoCD is already installed, as long as the version matches.
- (Add more directories as you add more cluster-wide tools, e.g., ingress controllers, monitoring, etc.)

## GitOps Workflow

This repository is intended to be managed by a GitOps tool such as **ArgoCD**. All changes to cluster-wide infrastructure should be made via pull requests and merged into the main branch, which is then automatically synchronized to the cluster by ArgoCD.

## ArgoCD Setup

1. **Install ArgoCD:**
   You can install ArgoCD using GitOps by adding the manifests to this repository (see `argocd/kustomization.yaml`).
   If you need to bootstrap ArgoCD manually, you can use:
   ```sh
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.0.4+5328bd5/manifests/install.yaml
   ```
   After bootstrapping, manage all future ArgoCD upgrades and configuration through GitOps by updating the manifests in `argocd/` and letting ArgoCD sync itself.

2. **Access ArgoCD UI:**
   Expose the ArgoCD API server (for example, using port-forward):
   ```sh
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
   Then open [https://localhost:8080](https://localhost:8080) in your browser.

3. **Login to ArgoCD:**
   The default username is `admin`. Get the password with:
   ```sh
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
   ```

4. **Register this repo as an ArgoCD Application:**
   Create an `Application` manifest or use the UI to point ArgoCD at this repository. Example manifest:
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: cluster-gitops
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: 'https://github.com/your-org/cluster-gitops.git'
       targetRevision: HEAD
       path: .
     destination:
       server: https://kubernetes.default.svc
       namespace: default
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   ```

## How ArgoCD is Managed (Self-Management)

ArgoCD is managed using GitOps in this repository:
- The `argocd/` directory contains a `kustomization.yaml` that references the ArgoCD install manifest for your chosen version.
- The `argocd/argocd-app.yaml` file is an ArgoCD Application resource that points to the `argocd/` directory, making ArgoCD manage itself ("app of apps").
- To enable this, apply the Application manifest:
  ```sh
  kubectl apply -f argocd/argocd-app.yaml
  ```
- After this, any changes to ArgoCD (version upgrades, config changes) should be made in the `argocd/` directory and committed to the repository. ArgoCD will automatically sync and apply these changes.

**Note:**
- The initial ArgoCD install (bootstrapping) can be done manually, but all future management should be through GitOps for safety and traceability.
- If the version in `argocd/kustomization.yaml` matches your running version, enabling GitOps management is safe and will not disrupt your cluster.

## App of Apps Pattern for Cluster Default Tooling

Cluster-wide tools are managed using the ArgoCD App of Apps pattern. Each tool (e.g., NFS CSI driver, Kubernetes Dashboard) is defined as a separate ArgoCD Application manifest in `cluster-default-tooling/`.

- The parent Application (`cluster-default-tooling-argocd.yaml`) uses `directory.recurse: true` to automatically discover and manage all child Application manifests in the same directory.
- To add a new tool, simply add a new `*-argocd.yaml` Application manifest in `cluster-default-tooling/`.
- This structure is scalable, maintainable, and avoids cross-directory references.

### Example Directory Structure

```
cluster-default-tooling/
  cluster-default-tooling-argocd.yaml   # Parent App of Apps
  nfs-csi-driver-argocd.yaml            # Child Application
  dashboard-argocd.yaml                 # Child Application
  ...
```

### How to Add a New Tool
1. Create a manifest for the tool (e.g., `my-tool-argocd.yaml`) in `cluster-default-tooling/`.
2. ArgoCD will automatically discover and manage it via the parent Application.

See each tool's subdirectory for specific configuration and usage details.

## Adding More Tools

- Add new directories for each cluster-wide tool (e.g., ingress, monitoring, logging).
- Add their manifests and update the main `kustomization.yaml` if you use one at the root.

## Notes

- All cluster-wide resources should be managed here for consistency and traceability.
- Sensitive data should be encrypted (e.g., using Sealed Secrets or SOPS).
- Review and test changes in a staging environment before applying to production.

---

For more details, see the documentation in each subdirectory (e.g., `storage/nfs-csi-driver/README.md`).
