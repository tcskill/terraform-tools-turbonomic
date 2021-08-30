
locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir      = "${path.cwd}/.tmp"
  //ingress_host = "${var.hostname}-${var.releases_namespace}.${var.cluster_ingress_hostname}"
  //scripts_dir      = "${path.cwd}/.tmp/${local.name}/scripts/${local.name}"
  //ingress_url  = "https://${local.ingress_host}"
  //service_url  = "http://sonarqube-sonarqube.${var.releases_namespace}:9000"
  //secret_name  = "sonarqube-access"
  //config_name  = "sonarqube-config"
  //config_sa_name = "sonarqube-config"
  //gitops_dir   = var.gitops_dir != "" ? var.gitops_dir : "${path.cwd}/gitops"
  //chart_dir    = "${local.gitops_dir}/sonarqube"
  //global_config    = {
  //  storageClass = var.storage_class
  //  clusterType = var.cluster_type
  //  ingressSubdomain = var.cluster_ingress_hostname
  }

  
module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
  
  clis = ["helm"]
}

resource "null_resource" "deploy_storageclass" {
    
  triggers = {
    kubeconfig = var.cluster_config_file
  }
    
  provisioner "local-exec" {
    command = "${path.module}/scripts/configStorageClass.sh"

      environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/configStorageClass.sh destroy"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}
  
resource "null_resource" "deploy_ClusterRole" {
  depends_on = [null_resource.deploy_storageclass]
  triggers = {
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/configClusterRole.sh"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/configClusterRole.sh destroy"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
} 

resource "null_resource" "add_scc" {
  depends_on = [null_resource.deploy_storageclass]
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.turbo_namespace
    tsaname = var.turbo_service_account_name
    tmp_dir      = "${path.cwd}/.tmp"
    bin_dir = module.setup_clis.bin_dir
  }
    
  provisioner "local-exec" {
    command = "${path.module}/scripts/configSCC.sh ${self.triggers.bin_dir} ${self.triggers.tsaname} ${self.triggers.namespace}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/configSCC.sh ${self.triggers.bin_dir} ${self.triggers.tsaname} ${self.triggers.namespace} destroy"
    
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
} 
  
resource "null_resource" "deploy_operator" {
  depends_on = [null_resource.add_scc, null_resource.deploy_ClusterRole]
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.turbo_namespace
    tsaname = var.turbo_service_account_name
  }
    
  provisioner "local-exec" {
    command = "${path.module}/scripts/installOperator.sh ${self.triggers.tsaname} ${self.triggers.namespace}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/installOperator.sh ${self.triggers.tsaname} ${self.triggers.namespace} destroy"
    
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
} 

