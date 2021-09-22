module "tools_turbo" {
  source = "./module"

  cluster_config_file      = module.dev_cluster.config_file_path
  cluster_type             = module.dev_cluster.platform.type_code
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  tls_secret_name          = module.dev_cluster.platform.tls_secret
  
  turbo_namespace               = "turbonomic"
  turbo_service_account_name    = "t8c-operator"
  turbo_probes                  = ["kubeturbo","instana","openshiftingress"]
  turbo_storage_class_provision = true
  turbo_cluster_is_vpc          = true
  turbo_storage_class_name      = "ibmc-vpc-block-10iops-mzr"
}