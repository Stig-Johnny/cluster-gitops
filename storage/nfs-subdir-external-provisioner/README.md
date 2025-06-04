# NFS Subdir External Provisioner for Kubernetes

This directory contains only demo and example manifests for testing NFS dynamic provisioning with the nfs-subdir-external-provisioner Helm chart. The actual NFS provisioner and StorageClass are managed by ArgoCD using the official Helm chart, not by static manifests in this directory.

## Contents

- `demo/` — Contains a kustomization and all manifests for the NFS demo namespace, PVC, and app. Use this for testing and demonstration purposes.
- `kustomization.yaml`: (Optional) For aggregating demo/test resources.
- `pvc.yaml`: Example PersistentVolumeClaim using the NFS StorageClass (for testing only; not required for production).
- `nfs-demo-app-argocd.yaml`: ArgoCD Application manifest for the NFS demo app. To apply it, run:

  ```sh
  kubectl apply -f demo/nfs-demo-app-argocd.yaml
  ```
  Or add it via the ArgoCD UI to manage the demo app via GitOps.

## Prerequisites

- An accessible NFS server at 100.95.36.122 exporting `/volume1/docker`.
- Kubernetes cluster v1.17+.
- [ArgoCD](https://argo-cd.readthedocs.io/) installed and managing this repository.

## How NFS Provisioning Works

- The nfs-subdir-external-provisioner is installed and managed via ArgoCD using the official Helm chart (see `cluster-default-tooling/nfs-subdir-external-provisioner-argocd.yaml`).
- The Helm chart creates the `nfs-csi` StorageClass and manages all dynamic provisioning.
- This directory is for demo/testing only and is not used for production provisioning.

## How to Test NFS Dynamic Provisioning

1. Ensure the nfs-subdir-external-provisioner is installed and running (via ArgoCD).
2. Apply the demo stack:
   ```sh
   kubectl apply -k demo/
   ```
   This will create:
   - A namespace `nfs-demo`
   - A PVC `nfs-demo-pvc` using the `nfs-csi` StorageClass
   - A demo app (busybox) mounting the NFS volume at `/mnt` and demonstrating read/write
3. You can `kubectl exec` into the pod to test read/write access to the NFS share.

## Example: Demo App

A sample deployment is provided in `demo/nfs-demo-app.yaml` to test NFS dynamic provisioning. It runs a BusyBox container that writes to a file on the NFS volume:

```yaml
command: ["sh", "-c", "echo Hello from NFS > /mnt/hello.txt && cat /mnt/hello.txt && sleep 3600"]
```

This demonstrates that the NFS volume is writable and persistent. The PVC used by this deployment must reference the StorageClass created by your NFS provisioner (e.g., `nfs-csi`).

## Notes

- The nfs-subdir-external-provisioner enables dynamic provisioning of NFS-backed persistent volumes.
- The StorageClass is managed by the Helm chart, not by static manifests in this directory.
- For production, secure your NFS server and restrict access as needed.
- All changes should be made via pull requests and managed by ArgoCD for full GitOps compliance.

For more details, see the [nfs-subdir-external-provisioner documentation](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner).
