# --- Karpenter IAM + SQS + controller resources -----------------------------
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = var.cluster_name

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "${var.cluster_name}-karpenter-node"
  namespace                     = "karpenter"

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "local_file" "karpenter_values" {
  content = yamlencode({
    settings = {
      clusterName       = var.cluster_name
      clusterEndpoint   = var.cluster_endpoint
      interruptionQueue = module.karpenter.queue_name
    }
    serviceAccount = {
      name      = "karpenter"
      namespace = "karpenter"
      create    = true
    }
    controller = {
      env : [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]
    }
  })
  filename = "${var.output_path}/karpenter-values.yaml"
}

resource "local_file" "ec2_node_classes" {
  filename = "${var.output_path}/ec2-node-classes.yaml"
  content  = <<EOT
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: al2023-standard
spec:
  amiFamily: AL2023
  role: ${var.cluster_name}-karpenter-node
  amiSelectorTerms:
    - alias: al2023@v20250813
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${var.cluster_name}-private
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${var.cluster_name}
  tags:
    karpenter.sh/discovery: ${var.cluster_name}
---
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: al2023-gpu
spec:
  amiFamily: AL2023
  role: ${var.cluster_name}-karpenter-node
  amiSelectorTerms:
    - name: "*amazon-eks-gpu*" # EKS-optimized accelerated AMI
      owner: "amazon"
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${var.cluster_name}-private
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${var.cluster_name}
  tags:
    karpenter.sh/discovery: ${var.cluster_name}
EOT
}

resource "local_file" "node_pools" {
  filename = "${var.output_path}/node-pools.yaml"
  content  = <<EOT
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: apps
spec:
  template:
    metadata:
      labels:
        intent: apps
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: al2023-standard
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ${jsonencode(var.apps_instance_families)}
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot","on-demand"]
  limits:
    cpu: ${var.apps_capacity_limits.cpu}
    memory: ${var.apps_capacity_limits.memory}
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s
---
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: gpu
spec:
  limits:
    nvidia.com/gpu: ${var.gpu_capacity_limit}
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s
  template:
    metadata:
      labels:
        workload: gpu
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: al2023-gpu
      taints:
        - key: nvidia.com/gpu
          value: "true"
          effect: NoSchedule
      requirements:
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ${jsonencode(var.gpu_instance_types)}
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand","spot"]
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
EOT
}
