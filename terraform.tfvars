// Modify values below as needed
# Aviatrix Controller
#controller_ip = "REPLACE_ME"
#username      = "REPLACE_ME"
#password      = "REPLACE_ME"

# Azure Access Account Name defined in Controller
azure_account_name = "Azure-Aviatrix"

# Aviatrix Gateway size
instance_size = "Standard_D3_v2"
# Test VM Kit
test_instance_size = "Standard_DS3_v2"

# HA flags
ha_enabled = false

# Transit Gateway Network Variables
// Transit
azure_transit_cidr1   = "10.21.2.0/20"
azure_region1         = "West US"
azure_vng_subnet_cidr = "10.21.6.0/27"

// Spokes
spokes = { "Dev" = "10.22.1.0/20" , "Test" = "10.23.3.0/20" } # and so on.., "Prod" = "10.24.3.0/20" }