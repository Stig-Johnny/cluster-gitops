# NFS Subdir External Provisioner for Kubernetes

This directory contains manifests and configuration for deploying the nfs-subdir-external-provisioner, a dynamic NFS provisioner for Kubernetes clusters.

## Contents

- `kustomization.yaml`: (Optional) For aggregating demo/test resources.
- `pvc.yaml`: Example PersistentVolumeClaim using the NFS StorageClass.
- `demo/` — Contains a kustomization and all manifests for the NFS demo namespace, PVC, and app. Use this for testing and demonstration purposes.

## Prerequisites

- An accessible NFS server at 100.95.36.122 exporting `/volume1/docker`.
- Kubernetes cluster v1.17+.
- [ArgoCD](https://argo-cd.readthedocs.io/) installed and managing this repository.

## How it works with ArgoCD

ArgoCD will automatically apply the manifests in this directory to your cluster, ensuring the NFS provisioner and storage configuration are always up to date and in sync with this repository.

### Steps

1. **Ensure ArgoCD is running and this repository is registered as an Application.**
2. **ArgoCD will sync the manifests:**
   - Installs the nfs-subdir-external-provisioner via Helm.
   - Creates the `nfs-csi` StorageClass pointing to your NFS server.
   - Optionally, creates the example PVC (`nfs-pvc`).
3. **Use the PVC in your workloads:**
   Reference `nfs-pvc` in your pod or deployment specs, or create your own PVCs using the `nfs-csi` StorageClass.

## How to add this storage stack to ArgoCD

To manage the NFS provisioner and storage configuration with ArgoCD, add an ArgoCD Application manifest that points to this directory. Example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nfs-subdir-external-provisioner
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/Stig-Johnny/cluster-gitops.git'
    targetRevision: HEAD
    path: storage/nfs-subdir-external-provisioner
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

1. Save this manifest as `nfs-subdir-external-provisioner-app.yaml` in your repo or apply it directly to your cluster:
   ```sh
   kubectl apply -f nfs-subdir-external-provisioner-app.yaml
   ```
2. ArgoCD will now keep the NFS provisioner and storage configuration in sync with this repository.

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

## NFS Demo App Example

A sample deployment is provided in `demo/nfs-demo-app.yaml` to test NFS dynamic provisioning. It runs a BusyBox container that writes to a file on the NFS volume:

```yaml
command: ["sh", "-c", "echo Hello from NFS > /mnt/hello.txt && cat /mnt/hello.txt && sleep 3600"]
```

This demonstrates that the NFS volume is writable and persistent. The PVC used by this deployment must reference the StorageClass created by your NFS provisioner (e.g., `nfs-csi`).

To deploy the demo app:
1. Ensure the NFS provisioner and StorageClass are working.
2. Apply the manifests in the `demo/` directory.
3. Check pod logs to verify the file was written and read from NFS.

## Notes

- The nfs-subdir-external-provisioner enables dynamic provisioning of NFS-backed persistent volumes.
- The provided StorageClass uses `Retain` reclaim policy by default.
- For production, secure your NFS server and restrict access as needed.
- All changes should be made via pull requests and managed by ArgoCD for full GitOps compliance.

For more details, see the [nfs-subdir-external-provisioner documentation](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner).
