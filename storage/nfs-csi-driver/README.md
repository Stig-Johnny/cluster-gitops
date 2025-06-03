# NFS CSI Driver for Kubernetes

This directory contains manifests and configuration for deploying the NFS CSI driver, a StorageClass, and an example PersistentVolumeClaim (PVC) for Kubernetes clusters.

## Contents

- `kustomization.yaml`: Deploys the NFS CSI driver controller and node components.
- `storageclass.yaml`: Defines a StorageClass using the NFS CSI driver.
- `pvc.yaml`: Example PersistentVolumeClaim using the NFS StorageClass.

## Prerequisites

- An accessible NFS server.
- Kubernetes cluster v1.17+.

## Setup

1. **Edit `storageclass.yaml`:**  
   Replace `<NFS_SERVER_IP>` and `/exported/path` with your NFS server's IP address and exported path.

2. **Deploy the NFS CSI driver:**
   ```sh
   kubectl apply -k storage/nfs-csi-driver/
   ```

3. **Create a PersistentVolumeClaim:**
   ```sh
   kubectl apply -f storage/nfs-csi-driver/pvc.yaml
   ```

4. **Use the PVC in your workloads:**  
   Reference `nfs-pvc` in your pod or deployment specs.

## Notes

- The NFS CSI driver enables dynamic provisioning of NFS-backed persistent volumes.
- The provided StorageClass uses `Retain` reclaim policy by default.
- For production, secure your NFS server and restrict access as needed.

For more details, see the [official NFS CSI driver documentation](https://github.com/kubernetes-csi/csi-driver-nfs).
