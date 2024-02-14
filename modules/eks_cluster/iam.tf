resource "aws_iam_role" "eks-iam" {
  name               = "eks-iam-role-${var.cluster_name}"
  assume_role_policy = file("./json_files/eksClusterRole.json")
}
resource "aws_iam_role" "eks-worker-role" {
  name               = "eks-worker-role-${var.cluster_name}"
  assume_role_policy = file("./json_files/eksWorkerRole.json")
}
resource "aws_iam_role_policy_attachment" "eks-role-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam.name

}
resource "aws_iam_role_policy_attachment" "worker-role-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-worker-role.name
}

resource "aws_iam_role_policy_attachment" "cni-role-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-worker-role.name
}

resource "aws_iam_role_policy_attachment" "ecr-role-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-worker-role.name
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "lb-policy" {
  policy = file("./json_files/AWSLoadBalancerControllerPolicy.json")
  name   = "AWSLoadBalancerControllerPolicy"
}
resource "aws_iam_role" "service-acc" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller"
}
resource "aws_iam_role_policy_attachment" "lb-policy-attach" {
  role       = aws_iam_role.service-acc.name
  policy_arn = aws_iam_policy.lb-policy.arn

}