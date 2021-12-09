module "dev_tools_namespace" {
  source = "github.com/ibm-garage-cloud/terraform-cluster-namespace?ref=v3.1.2"

  cluster_config_file_path = module.dev_cluster.config_file_path
  name                     = "turbonomic"
  create_operator_group    = true
}


resource null_resource write_namespace {
  provisioner "local-exec" {
    command = "echo 'turbonomic' > ${path.cwd}/namespace"
  }
}
