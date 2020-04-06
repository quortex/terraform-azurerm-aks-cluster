# Manages a Managed Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "quortex" {

  # The name of the Managed Kubernetes Cluster to create.
  name = var.cluster_name

  # The location where the Managed Kubernetes Cluster should be created.
  location = var.location

  # Specifies the Resource Group where the Managed Kubernetes Cluster should exist.
  resource_group_name = var.resource_group_name

  # The Kubernetes version.
  kubernetes_version = var.kubernetes_version

  # DNS prefix specified when creating the managed cluster.
  dns_prefix = var.cluster_dns_prefix

  service_principal {
    client_id     = var.service_principal_id
    client_secret = var.service_principal_secret
  }

  # The default nodepool will be used by tools (prometheus, grafana...).
  # It can be used with General purpose virtual machine sizes.
  default_node_pool {
    name                = "default"
    vm_size             = lookup(var.node_pool_default, "vm_size", "Standard_DS3_v2")
    enable_auto_scaling = true
    node_count          = lookup(var.node_pool_default, "node_min_count", 1)
    min_count           = lookup(var.node_pool_default, "node_min_count", 1)
    max_count           = lookup(var.node_pool_default, "node_max_count", 8)
    node_taints         = lookup(var.node_pool_default, "node_taints", null)
    max_pods            = lookup(var.node_pool_default, "max_pods", null)
    vnet_subnet_id      = var.cluster_subnet_id
  }

  network_profile {
    network_plugin     = var.cluster_network_plugin
    dns_service_ip     = var.cluster_dns_service_ip
    docker_bridge_cidr = var.cluster_docker_bridge_cidr
    service_cidr       = var.cluster_service_cidr
    pod_cidr           = var.cluster_pod_cidr

    # Standard LoadBalancer is required for multiple nodepools.
    load_balancer_sku = "standard"

    # Use a single IP for outbound traffic
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.outbound.id]
    }
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }

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
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.quortex.id
  vm_size               = lookup(each.value, "vm_size", "Standard_F16s_v2")
  enable_auto_scaling   = true
  node_count            = lookup(each.value, "node_min_count", 1)
  min_count             = lookup(each.value, "node_min_count", 1)
  max_count             = lookup(each.value, "node_max_count", 8)
  node_taints           = lookup(each.value, "node_taints", null)
  max_pods              = lookup(each.value, "max_pods", null)
  vnet_subnet_id        = var.cluster_subnet_id

  lifecycle {
    ignore_changes = [node_count]
  }
}

# The public IP to use as outbound IP form AKS managed LoadBalancer.
resource "azurerm_public_ip" "outbound" {
  name                = "${terraform.workspace}-outbound"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  # Standard sku required as it will be used by standard LoadBalancer.
  sku = "Standard"

  tags = var.tags
}
