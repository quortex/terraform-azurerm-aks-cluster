/**
 * Copyright 2020 Quortex
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "subscription_id" {
  type        = string
  description = "The Subscription ID which should be used."
}

variable "location" {
  type        = string
  description = "The location where the resources should be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create resources."
}

variable "name" {
  type        = string
  description = "A name from which the name of the resources will be chosen. Note that each resource name can be set individually."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
  default     = ""
}

variable "cluster_subnet_id" {
  type        = string
  description = "The AKS cluster dedicated subnet identifier."
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  default     = null
}

variable "cluster_dns_prefix" {
  type        = string
  description = "DNS prefix specified when creating the managed cluster."
  default     = ""
}

variable "service_principal_id" {
  type        = string
  description = "The Client ID of the Service Principal used for AKS cluster."
}

variable "service_principal_secret" {
  type        = string
  description = "The Client secret of the Service Principal used for AKS cluster."
}

variable "cluster_network_plugin" {
  type        = string
  description = "Network plugin to use for networking. Currently supported values are azure and kubenet."
  default     = "azure"
}

variable "cluster_dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). This is required when network_plugin is set to azure."
  default     = "10.0.0.10"
}

variable "cluster_docker_bridge_cidr" {
  type        = string
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. This is required when network_plugin is set to azure."
  default     = "172.17.0.1/16"
}

variable "cluster_service_cidr" {
  type        = string
  description = "The Network Range used by the Kubernetes service. This is required when network_plugin is set to azure."
  default     = "10.0.0.0/16"
}

variable "cluster_pod_cidr" {
  type        = string
  description = "The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet."
  default     = null
}

variable "cluster_outbound_ip_name" {
  type        = string
  description = "The name of the public IP address used for cluster's outbound traffic."
  default     = ""
}

variable "kube_dashboard_enabled" {
  type        = bool
  description = "Whether to enable kube dashboard."
  default     = false
}

variable "node_pool_default" {
  type        = any
  description = "The cluster default node pool configuration. Defined as a block following official documentation (https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#default_node_pool) for these values => vm_size, node_min_count, node_max_count, node_taints"
  default     = {}
}

variable "node_pool_additionals" {
  type        = any
  description = "The cluster additional node pools configuration. Defined as a map whick key defines the node name and value is a block following official documentation (https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#default_node_pool) for these values => vm_size, node_min_count, node_max_count, node_taints"
  default     = {}
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources. A list of key->value pairs."
  default     = {}
}
