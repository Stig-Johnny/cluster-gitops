# Apps (ArgoCD Application Manifests)

This directory contains all ArgoCD Application manifests for cluster-wide tools and infrastructure, such as NFS storage, Kubernetes Dashboard, and more. This follows GitOps best practices for a clean, scalable, and maintainable structure.

## Structure
- `apps-argocd.yaml`: (Optional) App of Apps parent manifest for managing all child Applications in this directory.
- `nfs-subdir-external-provisioner-argocd.yaml`: ArgoCD Application manifest for NFS dynamic provisioning.
- `dashboard-argocd.yaml`: ArgoCD Application manifest for Kubernetes Dashboard.
- ...add more Application manifests as needed.

## Usage
- Register the App of Apps manifest (if used) or individual Application manifests with ArgoCD to manage cluster-wide tools declaratively.
- See each Application manifest for configuration and customization options.

## Best Practices
- Keep all cluster-wide ArgoCD Application manifests in this directory for clarity and maintainability.
- Use the App of Apps pattern for scalable management.
- Document each Application and its purpose in this README or in dedicated files.
