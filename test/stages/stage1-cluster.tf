module "dev_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-ocp?ref=v1.7.0"

  resource_group_name     = var.resource_group_name
  region                  = var.region
  ibmcloud_api_key        = var.ibmcloud_api_key
  name                    = var.cluster_name
  worker_count            = 2
  ocp_version             = "4.6"
  name_prefix             = var.name_prefix
  exists                  = true
  cos_id                  = ""
  vpc_subnet_count        = 0
  vpc_name                = ""
  vpc_subnets             = []

}

resource null_resource write_kubeconfig {
  provisioner "local-exec" {
    command = "echo '${module.dev_cluster.platform.kubeconfig}' > ${path.cwd}/kubeconfig"
  }
}