#  Turbonomic terraform module

![Verify and release module](https://github.com/cloud-native-toolkit/terraform-tools-turbonomic/workflows/Verify%20and%20release%20module/badge.svg)


Deploys Turbonomic operator into the cluster and creates an instance. By default, the kubeturbo probe is also installed into the cluster along with the OpenShift ingress.  Other probes to deploy can be specified in the turbo_probes variable, by default it will deploy:  turboprobe, openshift ingress, and instana.  The namespace to deploy within the cluster is defined in the variables, default is Turbonomic.  Also note if deploying on mzr cluster you'll need the custom storage created, default is true to create this automatically, if not mzr you can set to false and use whatever storage class you'd like.

### Supported Component Selector Probe Types 
Use these names in the `turbo_probes` variable to define additional probes as needed for your environment:
```
"kubeturbo","instana","openshiftingress", "aws", "azure", "prometheus", "servicenow", "tomcat", "jvm", "websphere", "weblogic"
```

## Supported platforms

- OCP 4.6+

## Module dependencies

The module uses the following elements

### Terraform providers

- helm - used to configure the scc for OpenShift
- null - used to run the shell scripts

### Environment

- kubectl - used to apply the yaml to create the route

## Suggested companion modules

The module itself requires some information from the cluster and needs a
namespace to be created. The following companion
modules can help provide the required information:

- Cluster - https://github.com/ibm-garage-cloud/terraform-cluster-ibmcloud
- Namespace - https://github.com/ibm-garage-cloud/terraform-cluster-namespace


## Example usage

```hcl-terraform
module "dev_tools_turbonomic" {
  source = "github.com/cloud-native-toolkit/terraform-tools-turbonomic?ref=v1.0.0"

  cluster_type             = var.cluster_type
  cluster_ingress_hostname = module.dev_cluster.ingress_hostname
  cluster_config_file      = module.dev_cluster.config_file_path
  releases_namespace       = module.dev_cluster_namespaces.tools_namespace_name
  tls_secret_name          = module.dev_cluster.tls_secret_name
}
```
