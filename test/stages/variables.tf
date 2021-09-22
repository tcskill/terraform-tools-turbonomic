
variable "resource_group_name" {
  type        = string
  description = "Existing resource group where the IKS cluster will be provisioned."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The api key for IBM Cloud access"
}

variable "region" {
  type        = string
  description = "Region for VLANs defined in private_vlan_number and public_vlan_number."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = ""
}

variable "cluster_type" {
  type        = string
  description = "The type of cluster that should be created (openshift or kubernetes)"
}

variable "name_prefix" {
  type        = string
  description = "Prefix name that should be used for the cluster and services. If not provided then resource_group_name will be used"
  default     = ""
}

variable "turbo_namespace" {
  type = string
  description = "The namespace that should be created"
 // default = "turbonomic"
}
variable "turbo_service_account_name" {
  type = string
  description = "The namespace that should be created"
  default = "t8c-operator"
}
variable "turbo_probes" {
  description = "The probes to deploy with turbonomic"
  type        = list(string)
  //default     = ["kubeturbo","instana","openshiftingress"]
}
variable "turbo_storage_class_provision" {
  description = "Flag indicating that an ibm block custom storage class should be created and used"
  type        = bool
 // default     = true
}

variable "turbo_cluster_is_vpc" {
  type        = bool
  description = "Set to false if installing on ibm classic cluster, true for vpc cluster"
  //default     = true
}

variable "turbo_storage_class_name" {
  description = "Name of the storage class to use"
  type        = string
 // default     = "ibmc-vpc-block-10iops-mzr"
} 