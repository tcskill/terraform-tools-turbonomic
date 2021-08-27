module "tools_turbo" {
  source = "./module"

  cluster_config_file      = module.dev_cluster.config_file_path
  cluster_type             = module.dev_cluster.platform.type_code
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  tls_secret_name          = module.dev_cluster.platform.tls_secret
  namespace                = module.dev_capture_state.namespace
  service_account_name     = var.turbo_service_account_name
  turbo_namespace          = var.turbo_namespace

}
