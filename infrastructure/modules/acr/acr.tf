#
resource "azurerm_container_registry" "example" {
  #var.prefix was created to give originality and individualty to each resource created, it is "ecomProject"
  name                     = "${var.prefix}AzureContRegist"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  sku                      = "Standard"
  admin_enabled            = true
  tags = {
    Environment = "Development"
    Creator = "Terraform"
  }
}