resource "null_resource" "update-kubeconfig" {
  depends_on = [aws_eks_cluster.sin-eks]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}"
  }
}

# resource "null_resource" "patch-coredns-fargate" {
#   depends_on = [aws_eks_fargate_profile.fargate-prof-1, aws_eks_fargate_profile.fargate-prof-2]
#   provisioner "local-exec" {
#     command = "/bin/bash ./script/patchCoreDNS.sh"
#   }
# }

resource "null_resource" "kubectl-apply" {
   depends_on = [ aws_eks_node_group.eks-node-grp ]
   provisioner "local-exec" {
     command = "/bin/bash ./script/argocd.sh"
   }
 }

