[![Quortex][logo]](https://quortex.io)
# terraform-azurerm-aks-cluster
A terraform module for Quortex infrastructure AKS cluster layer.

It provides a set of resources necessary to provision the Quortex infrastructure AKS cluster layer on Microsoft Azure.

This module is available on [Terraform Registry][registry_tf_azurerm_aks_cluster].

Get all our terraform modules on [Terraform Registry][registry_tf_modules] or on [Github][github_tf_modules] !

## Created resources

This module creates the following resources on Azure:

- a fully configurable AKS cluster and node pools
- a public IP for cluster's outbound traffic


## Usage example

```hcl
module "aks-cluster" {
  source = "quortex/aks-cluster/azurerm"

  # Globally used variables.
  subscription_id     = local.subscription_id
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  name                = "quortex"

  # Cluster configuration.
  cluster_subnet_id        = module.network.cluster_subnet_id
  kubernetes_version       = "1.15.10"
  service_principal_id     = local.aks_service_principal_id
  service_principal_secret = local.aks_service_principal_secret
  node_pool_default = {
    vm_size        = "Standard_DS3_v2"
    node_min_count = 1
    node_max_count = 2
  }
  node_pool_additionals = {
    workflow = {
      vm_size        = "Standard_F16s_v2"
      node_min_count = 2
      node_max_count = 3
    }
  }
}
```

---

## Related Projects

This project is part of our terraform modules to provision a Quortex infrastructure for Microsoft Azure.

![infra_azure]

Check out these related projects.

- [terraform-azurerm-network][registry_tf_azurerm_network] - A terraform module for Quortex infrastructure network layer.

- [terraform-azurerm-load-balancer][registry_tf_azurerm_load_balancer] - A terraform module for Quortex infrastructure Azure load balancing layer.

- [terraform-azurerm-storage][registry_tf_azurerm_storage] - A terraform module for Quortex infrastructure Azure persistent storage layer.

## Help

**Got a question?**

File a GitHub [issue](https://github.com/quortex/terraform-azurerm-aks-cluster/issues) or send us an [email][email].


  [logo]: https://storage.googleapis.com/quortex-assets/logo.webp
  [email]: mailto:info@quortex.io
  [infra_azure]: https://storage.googleapis.com/quortex-assets/infra_azure_001.jpg
  [registry_tf_modules]: https://registry.terraform.io/modules/quortex
  [registry_tf_azurerm_network]: https://registry.terraform.io/modules/quortex/network/azurerm
  [registry_tf_azurerm_aks_cluster]: https://registry.terraform.io/modules/quortex/aks-cluster/azurerm
  [registry_tf_azurerm_load_balancer]: https://registry.terraform.io/modules/quortex/load-balancer/azurerm
  [registry_tf_azurerm_storage]: https://registry.terraform.io/modules/quortex/storage/azurerm
  [github_tf_modules]: https://github.com/quortex?q=terraform-