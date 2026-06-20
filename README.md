# GPU EKS cluster

A minimal Terraform + Helmfile setup that brings up an EKS cluster with
Karpenter-managed CPU and GPU node pools. Three steps to a working cluster.

> **Heads up:** the cluster is configured with `endpoint_public_access = true`,
> so the Kubernetes API is reachable from the internet (auth still required).
> The VPC also uses `single_nat_gateway = true` — cost-friendly for a solo
> project, but a single point of failure for anything production. Review
> `modules/eks/main.tf` and `modules/karpenter/variables.tf` before applying
> in any account you care about.

## 1. Bring up the base infra

```sh
terraform apply
```

This creates a VPC, the EKS control plane, and the Karpenter IAM/SQS resources.
It also writes the following files into `manifests/`:

- `karpenter-values.yaml` — values consumed by `helmfile.yaml`
- `ec2-node-classes.yaml`, `node-pools.yaml` — Karpenter CRs applied in step 3

Once apply finishes, point kubectl at the new cluster:

```sh
aws eks update-kubeconfig \
  --region us-east-1 \
  --name "$(terraform output -raw cluster_name)" \
  --role-arn "$(terraform output -raw admin_role_arn)"
```

Cluster access is gated on assuming the admin role created by the `iam`
module — anyone in the same AWS account can assume it.

## 2. Install core services

```sh
helm plugin install https://github.com/databus23/helm-diff
helmfile apply
```

Installs the Karpenter controller (and CRDs) and the NVIDIA device plugin.

## 3. Create node pools

```sh
kubectl apply -f manifests/ec2-node-classes.yaml
kubectl apply -f manifests/node-pools.yaml
```

EC2NodeClasses must be applied before NodePools that reference them.
