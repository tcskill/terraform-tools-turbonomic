
locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir      = "${path.cwd}/.tmp"
  ingress_host = "${var.hostname}-${var.releases_namespace}.${var.cluster_ingress_hostname}"
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

resource null_resource install_helm_chart {
  provisioner "local-exec" {
    command = "${local.bin_dir}/helm install ..."
  }
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
    }
    
    provisioner "local-exec" {
      //command = "${local.bin_dir}/helm install ..."
      // helm template service-account service-account --repo https://charts.cloudnativetoolkit.dev --set "name=${SANAME}" --set "sccs[0]=anyuid" --set create=true --set "-n=${NAMESPACE}" > "${TMP_DIR}/turboscc.yaml"
      //command = "${local.bin_dir}/helm template service-account --repo https://charts.cloudnativetoolkit.dev --set 'name=t8c-operator' --set 'sccs[0]=anyuid' --set create=true --set '-n=${self.triggers.namespace}' > '${self.triggers.tmp_dir}/turboscc.yaml'"
      command = "${local.bin_dir}/helm template service-account --repo https://charts.cloudnativetoolkit.dev --set 'name=${self.triggers.tsaname}' --set 'sccs[0]=anyuid' --set create=true --set '-n=${self.triggers.namespace}' | 'kubectl apply -n ${self.triggers.namespace} -f -'"
    }

    /*provisioner "local-exec" {
      command = "${path.module}/scripts/configSCC.sh ${self.triggers.namespace}"

      environment = {
        KUBECONFIG = self.triggers.kubeconfig
      }
    }*/

    provisioner "local-exec" {
      when = destroy
      //command = "${path.module}/scripts/configSCC.sh ${self.triggers.namespace} destroy"
      command = "${local.bin_dir}/helm template service-account --repo https://charts.cloudnativetoolkit.dev --set 'name=${self.triggers.tsaname}' --set 'sccs[0]=anyuid' --set create=true --set '-n=${self.triggers.namespace}' | 'kubectl delete -n ${self.triggers.namespace} -f -'"
      environment = {
        KUBECONFIG = self.triggers.kubeconfig
      }
    }
  } 
  

  /* sonarqube_config = {
    image = {
      pullPolicy = "Always"
    }
    persistence = {
      enabled = false
      storageClass = var.storage_class
    }
    serviceAccount = {
      create = true
      name = var.service_account_name
    }
    podLabels = {
      "app.kubernetes.io/part-of" = "sonarqube"
    }
     postgresql = {
      enabled = !var.postgresql.external
      postgresqlServer = var.postgresql.external ? var.postgresql.hostname : ""
      postgresqlDatabase = var.postgresql.external ? var.postgresql.database_name : "sonarDB"
      postgresqlUsername = var.postgresql.external ? var.postgresql.username : "sonarUser"
      postgresqlPassword = var.postgresql.external ? var.postgresql.password : "sonarPass"
      service = {
        port = var.postgresql.external ? var.postgresql.port : 5432
      }
      serviceAccount = {
        enabled = true
        name = var.service_account_name
      }
      persistence = {
        enabled = false
        storageClass = var.storage_class
      }
      volumePermissions = {
        enabled = false
      }
      master = {
        labels = {
          "app.kubernetes.io/part-of" = "sonarqube"
        }
        podLabels = {
          "app.kubernetes.io/part-of" = "sonarqube"
        }
      }
    } 
    ingress = {
      enabled = var.cluster_type == "kubernetes"
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
        "nginx.ingress.kubernetes.io/proxy-body-size" = "20m"
        "ingress.kubernetes.io/proxy-body-size" = "20M"
        "ingress.bluemix.net/client-max-body-size" = "20m"
      }
      hosts = [{
        name = local.ingress_host
      }]
      tls = [{
        secretName = var.tls_secret_name
        hosts = [
          local.ingress_host
        ]
      }]
    }
    plugins = {
      install = var.plugins
    }
    enableTests = false
  } 
  /*service_account_config = {
    name = var.service_account_name
    create = false
    sccs = ["anyuid", "privileged"]
  }
  config_service_account_config = {
    name = local.config_sa_name
    roles = [
      {
        apiGroups = [
          ""
        ]
        resources = [
          "secrets",
          "configmaps"
        ]
        verbs = [
          "*"
        ]
      }
    ]
  } 
  ocp_route_config       = {
    nameOverride = "sonarqube"
    targetPort = "http"
    app = "sonarqube"
    serviceName = "sonarqube-sonarqube"
    termination = "edge"
    insecurePolicy = "Redirect"
  }
  tool_config = {
    name = "SonarQube"
    url = local.ingress_url
    privateUrl = local.service_url
    username = "admin"
    password = "admin"
    applicationMenu = true
  }
  job_config             = {
    name = "sonarqube"
    serviceAccountName = local.config_sa_name
    command = "setup-sonarqube"
    secret = {
      name = local.secret_name
      key  = "SONARQUBE_URL"
    }
  }
} 

resource "null_resource" "setup-chart" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.chart_dir} && cp -R ${path.module}/chart/sonarqube/* ${local.chart_dir}"
  }
}

resource "null_resource" "delete-consolelink" {
  count = var.cluster_type != "kubernetes" ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl delete consolelink -l grouping=garage-cloud-native-toolkit -l app=sonarqube || exit 0"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}

resource "local_file" "sonarqube-values" {
  content  = yamlencode({
    global = local.global_config
    sonarqube = local.sonarqube_config
    service-account = local.service_account_config
    config-service-account = local.config_service_account_config
    ocp-route = local.ocp_route_config
    tool-config = local.tool_config
    setup-job = local.job_config
  })
  filename = "${local.chart_dir}/values.yaml"
}

resource "null_resource" "print-values" {
  provisioner "local-exec" {
    command = "cat ${local_file.sonarqube-values.filename}"
  }
}

resource "null_resource" "scc-cleanup" {
  depends_on = [local_file.sonarqube-values]
  count = var.mode != "setup" ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl delete scc -l app.kubernetes.io/name=sonarqube-sonarqube --wait 1> /dev/null 2> /dev/null || true"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
}

resource "helm_release" "sonarqube" {
  depends_on = [local_file.sonarqube-values, null_resource.scc-cleanup]
  count = var.mode != "setup" ? 1 : 0

  name              = "sonarqube"
  chart             = local.chart_dir
  namespace         = var.releases_namespace
  timeout           = 1200
  dependency_update = true
  force_update      = true
  replace           = true

  disable_openapi_validation = true

  values = [local_file.sonarqube-values.content]
}

resource "null_resource" "wait-for-config-job" {
  depends_on = [helm_release.sonarqube]
  count = var.mode != "setup" ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl wait -n ${var.releases_namespace} --for=condition=complete --timeout=30m job -l app=sonarqube"

    environment = {
      KUBECONFIG = var.cluster_config_file
    }
  }
} */
