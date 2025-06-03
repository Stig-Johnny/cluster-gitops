# Cluster GitOps

This repository manages cluster-wide tools and operators for your Kubernetes cluster using GitOps principles. It is designed to be the central place for deploying and managing shared infrastructure components that all other application GitOps repositories depend on.

## Structure

- `storage/nfs-csi-driver/` — NFS CSI driver manifests, StorageClass, and example PVC for NFS-based persistent storage.
- (Add more directories as you add more cluster-wide tools, e.g., ingress controllers, monitoring, etc.)

## GitOps Workflow

This repository is intended to be managed by a GitOps tool such as **ArgoCD**. All changes to cluster-wide infrastructure should be made via pull requests and merged into the main branch, which is then automatically synchronized to the cluster by ArgoCD.

## ArgoCD Setup

1. **Install ArgoCD:**
   You can install ArgoCD using the official manifests:
   ```sh
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

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

## Adding More Tools

- Add new directories for each cluster-wide tool (e.g., ingress, monitoring, logging).
- Add their manifests and update the main `kustomization.yaml` if you use one at the root.

## Notes

- All cluster-wide resources should be managed here for consistency and traceability.
- Sensitive data should be encrypted (e.g., using Sealed Secrets or SOPS).
- Review and test changes in a staging environment before applying to production.

---

For more details, see the documentation in each subdirectory (e.g., `storage/nfs-csi-driver/README.md`).
