# Manages a Managed Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "quortex" {

  # The name of the Managed Kubernetes Cluster to create.
  name = length(var.cluster_name) > 0 ? var.cluster_name : var.name

  # The location where the Managed Kubernetes Cluster should be created.
  location = var.location

  # Specifies the Resource Group where the Managed Kubernetes Cluster should exist.
  resource_group_name = var.resource_group_name

  # The Kubernetes version.
  kubernetes_version = var.kubernetes_version

  # DNS prefix specified when creating the managed cluster.
  dns_prefix = length(var.cluster_dns_prefix) > 0 ? var.cluster_dns_prefix : var.name

  service_principal {
    client_id     = var.service_principal_id
    client_secret = var.service_principal_secret
  }

  # The SKU Tier that should be used for this Kubernetes Cluster.
  # Possible values are Free and Paid (which includes the Uptime SLA).
  sku_tier                = var.sku_tier
  node_os_upgrade_channel = var.node_os_upgrade_channel
  cost_analysis_enabled   = var.cost_analysis_enabled

  # The default nodepool will be used by tools (prometheus, grafana...).
  # It can be used with General purpose virtual machine sizes.
  default_node_pool {
    name                     = "default"
    vm_size                  = lookup(var.node_pool_default, "vm_size", "Standard_DS3_v2")
    zones                    = lookup(var.node_pool_default, "zones", [])
    node_public_ip_enabled   = lookup(var.node_pool_default, "node_public_ip_enabled", false)
    node_public_ip_prefix_id = lookup(var.node_pool_default, "node_public_ip_prefix_id", null) == null ? null : azurerm_public_ip_prefix.default_nodepool[0].id
    auto_scaling_enabled     = true
    node_count               = lookup(var.node_pool_default, "node_min_count", 1)
    min_count                = lookup(var.node_pool_default, "node_min_count", 1)
    max_count                = lookup(var.node_pool_default, "node_max_count", 8)
    max_pods                 = lookup(var.node_pool_default, "max_pods", null)
    os_disk_type             = lookup(var.node_pool_default, "os_disk_type", "Managed")
    os_disk_size_gb          = lookup(var.node_pool_default, "os_disk_size_gb", 128)
    ultra_ssd_enabled        = lookup(var.node_pool_default, "ultra_ssd_enabled", false)

    vnet_subnet_id = var.cluster_subnet_id
  }

  network_profile {
    network_plugin = var.cluster_network_plugin
    dns_service_ip = var.cluster_dns_service_ip
    service_cidr   = var.cluster_service_cidr
    pod_cidr       = var.cluster_pod_cidr

    # Standard LoadBalancer is required for multiple nodepools.
    load_balancer_sku = "standard"

    # Use a single IP for outbound traffic
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.outbound.id]
    }
  }
  http_application_routing_enabled = false

  tags = var.tags

  lifecycle {
    ignore_changes = [default_node_pool.0.node_count, windows_profile]
  }

  depends_on = [azurerm_public_ip.outbound]
}

# The cluster additional node pools.
# Workflow nodepool used by Quortex apps requires Compute optimized
# virtual machine sizes with at least 16 vCPUs.
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.node_pool_additionals

  # The name of the node pool.
  name                     = each.key
  kubernetes_cluster_id    = azurerm_kubernetes_cluster.quortex.id
  zones                    = lookup(each.value, "zones", [])
  vm_size                  = lookup(each.value, "vm_size", "Standard_F16s_v2")
  node_public_ip_enabled   = lookup(each.value, "node_public_ip_enabled", false)
  node_public_ip_prefix_id = lookup(each.value, "node_public_ip_prefix_id", null) == null ? null : azurerm_public_ip_prefix.nodepool[each.key].id
  auto_scaling_enabled     = true
  node_count               = lookup(each.value, "node_min_count", 1)
  min_count                = lookup(each.value, "node_min_count", 1)
  max_count                = lookup(each.value, "node_max_count", 8)
  max_pods                 = lookup(each.value, "max_pods", null)
  node_taints              = lookup(each.value, "node_taints", null)
  os_disk_type             = lookup(each.value, "os_disk_type", "Managed")
  os_disk_size_gb          = lookup(each.value, "os_disk_size_gb", 128)
  ultra_ssd_enabled        = lookup(each.value, "ultra_ssd_enabled", false)

  vnet_subnet_id = var.cluster_subnet_id

  lifecycle {
    ignore_changes = [node_count]
  }
}

# Public IP pool for default nodepool
resource "azurerm_public_ip_prefix" "default_nodepool" {
  count = lookup(var.node_pool_default, "node_public_ip_prefix_id", 0) == 0 ? 0 : 1

  name                = "default"
  location            = var.location
  resource_group_name = var.resource_group_name

  prefix_length = var.node_pool_default["node_public_ip_prefix_id"]
  zones         = var.public_ip_zones
  tags          = var.tags
}

# Public IP pool to assign to additionnal nodepool
resource "azurerm_public_ip_prefix" "nodepool" {
  for_each = toset([for k, v in var.node_pool_additionals : k if lookup(v, "node_public_ip_prefix_id", null) != null])

  name                = each.value
  location            = var.location
  resource_group_name = var.resource_group_name

  prefix_length = var.node_pool_additionals[each.value]["node_public_ip_prefix_id"]
  zones         = var.public_ip_zones
  tags          = var.tags
}

# The public IP to use as outbound IP form AKS managed LoadBalancer.
resource "azurerm_public_ip" "outbound" {
  name                = length(var.cluster_outbound_ip_name) > 0 ? var.cluster_outbound_ip_name : "${var.name}-outbound"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  zones               = var.public_ip_zones
  # Standard sku required as it will be used by standard LoadBalancer.
  sku  = "Standard"
  tags = var.tags
}
