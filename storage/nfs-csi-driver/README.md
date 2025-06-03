# NFS CSI Driver for Kubernetes

This directory contains manifests and configuration for deploying the NFS CSI driver, a StorageClass, and an example PersistentVolumeClaim (PVC) for Kubernetes clusters.

## Contents

- `kustomization.yaml`: Deploys the NFS CSI driver controller and node components.
- `storageclass.yaml`: Defines a StorageClass using the NFS CSI driver, configured for your NFS server at 100.95.36.122:/volume1/docker.
- `pvc.yaml`: Example PersistentVolumeClaim using the NFS StorageClass.
- `nfs-demo-namespace.yaml`: Example namespace for demoing NFS storage.
- `nfs-demo-pvc.yaml`: Example PersistentVolumeClaim in the demo namespace using the NFS StorageClass.
- `nfs-demo-app.yaml`: Example Deployment mounting the NFS PVC in the demo namespace.
- `demo/` — Contains a kustomization and all manifests for the NFS demo namespace, PVC, and app. Use this for testing and demonstration purposes.

## Prerequisites

- An accessible NFS server at 100.95.36.122 exporting `/volume1/docker`.
- Kubernetes cluster v1.17+.
- [ArgoCD](https://argo-cd.readthedocs.io/) installed and managing this repository.

## How it works with ArgoCD

ArgoCD will automatically apply the manifests in this directory to your cluster, ensuring the NFS CSI driver and storage configuration are always up to date and in sync with this repository.

### Steps

1. **Ensure ArgoCD is running and this repository is registered as an Application.**
2. **ArgoCD will sync the manifests:**
   - Installs the NFS CSI driver components.
   - Creates the `nfs-csi` StorageClass pointing to your NFS server.
   - Optionally, creates the example PVC (`nfs-pvc`).
3. **Use the PVC in your workloads:**
   Reference `nfs-pvc` in your pod or deployment specs, or create your own PVCs using the `nfs-csi` StorageClass.

## How to add this storage stack to ArgoCD

To manage the NFS CSI driver and storage configuration with ArgoCD, add an ArgoCD Application manifest that points to this directory. Example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nfs-csi-driver
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/Stig-Johnny/cluster-gitops.git'
    targetRevision: HEAD
    path: storage/nfs-csi-driver
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

1. Save this manifest as `nfs-csi-driver-app.yaml` in your repo or apply it directly to your cluster:
   ```sh
   kubectl apply -f nfs-csi-driver-app.yaml
   ```
2. ArgoCD will now keep the NFS CSI driver and storage configuration in sync with this repository.

## How ArgoCD is Managed

ArgoCD is managed using GitOps in this repository. The `argocd/` directory contains a `kustomization.yaml` referencing the official ArgoCD install manifest, and an Application manifest (`argocd-app.yaml`) that makes ArgoCD manage itself. To enable this, apply the Application manifest:

```sh
kubectl apply -f argocd/argocd-app.yaml
```

After this, any changes to ArgoCD (such as version upgrades) should be made in the `argocd/` directory and committed to the repository. ArgoCD will automatically sync and apply these changes.

## Example: Using the PVC in a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nfs-test-pod
spec:
  containers:
    - name: app
      image: busybox
      command: ["sleep", "3600"]
      volumeMounts:
        - name: nfs-vol
          mountPath: /mnt
  volumes:
    - name: nfs-vol
      persistentVolumeClaim:
        claimName: nfs-pvc
```

## Example: Demo Namespace, PVC, and App

To try out NFS storage, apply the demo stack with:

```sh
kubectl apply -k demo/
```

Or, add the ArgoCD Application manifest (`nfs-demo-app-argocd.yaml`) to ArgoCD to manage the demo via GitOps.

This will create:
- A namespace `nfs-demo`
- A PVC `nfs-demo-pvc` using the `nfs-csi` StorageClass
- A demo app (busybox) mounting the NFS volume at `/mnt` and demonstrating read/write

You can `kubectl exec` into the pod to test read/write access to the NFS share.

## Notes

- The NFS CSI driver enables dynamic provisioning of NFS-backed persistent volumes.
- The provided StorageClass uses `Retain` reclaim policy by default.
- For production, secure your NFS server and restrict access as needed.
- All changes should be made via pull requests and managed by ArgoCD for full GitOps compliance.

For more details, see the [official NFS CSI driver documentation](https://github.com/kubernetes-csi/csi-driver-nfs).
