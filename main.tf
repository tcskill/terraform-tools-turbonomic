locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir = "${path.cwd}/.tmp"
}


module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["helm"]
}


resource "null_resource" "deploy_storageclass" {
  count = var.storage_class_provision ? 1 : 0
  triggers = {
    storname = var.storage_class_name
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/createStorageClass.sh ${self.triggers.storname}"

      environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/destroyStorageClass.sh ${self.triggers.storname}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

resource "null_resource" "deploy_ClusterRole" {
  triggers = {
    namespace = var.namespace
    tsaname = var.service_account_name
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/configClusterRole.sh ${self.triggers.tsaname} ${self.triggers.namespace}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/configClusterRole.sh ${self.triggers.tsaname} ${self.triggers.namespace} destroy"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
} 

resource "null_resource" "add_scc" {
  depends_on = [null_resource.deploy_ClusterRole]
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.namespace
    tsaname = var.service_account_name
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
  depends_on = [null_resource.add_scc]
  triggers = {
    kubeconfig = var.cluster_config_file
    namespace = var.namespace
    tsaname = var.service_account_name
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
    namespace = var.namespace
    probes = join(",", var.probes)
    storname = var.storage_class_name
    kubeconfig = var.cluster_config_file
    tsaname = var.service_account_name
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployInstance.sh ${self.triggers.namespace} '${self.triggers.probes}' ${self.triggers.storname} ${self.triggers.tsaname}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/deployInstance.sh ${self.triggers.namespace} '${self.triggers.probes}' ${self.triggers.storname} ${self.triggers.tsaname} destroy"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}
