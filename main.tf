locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir = "${path.cwd}/.tmp"
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
  depends_on = [module.namespace, null_resource.deploy_storageclass]
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

resource "null_resource" "deploy_instance" {
  depends_on = [null_resource.deploy_operator]
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.turbo_namespace
    probes = "${join(",", var.turbo_probes)}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployInstance.sh ${self.triggers.namespace} '${self.triggers.probes}'"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/deployInstance.sh ${self.triggers.namespace} '${self.triggers.probes}' destroy"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}
