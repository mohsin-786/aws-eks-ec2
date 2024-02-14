resource "aws_eks_cluster" "sin-eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-iam.arn
  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = false
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids = [
      aws_subnet.pubnet-1.id,
      aws_subnet.pubnet-2.id,
      aws_subnet.privnet-1.id,
      aws_subnet.privnet-2.id
    ]
  }
  depends_on = [aws_iam_role_policy_attachment.eks-role-attach]
}

resource "aws_eks_node_group" "eks-node-grp" {
  cluster_name = aws_eks_cluster.sin-eks.name
  node_group_name = "sins-nodes"
  node_role_arn = aws_iam_role.eks-worker-role.arn
  capacity_type = "ON_DEMAND"
  instance_types = [ "t2.medium" ]
  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }
  subnet_ids = [ aws_subnet.privnet-1.id, aws_subnet.privnet-2.id ]
  depends_on = [ aws_iam_role_policy_attachment.cni-role-attach, aws_iam_role_policy_attachment.ecr-role-attach, aws_iam_role_policy_attachment.worker-role-attach ]
}