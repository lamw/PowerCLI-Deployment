# William Lam
# Edited by Simon Eady to support vDS
# www.virtuallyghetto.com
# Deployment of vRealize Operations Manager 6.0 (vROps)

### NOTE: SSH can not be enabled because hidden properties do not seem to be implemented in Get-OvfConfiguration cmdlet ###

# Load OVF/OVA configuration into a variable
$ovffile = "E:\automation\vRealize-Operations-Manager-Appliance-6.0.1.2523163_OVF10.ova"
$ovfconfig = Get-OvfConfiguration $ovffile

# vSphere Cluster + VM Network configurations
$Cluster = "lab"
$VMName = "auto-vrops6"
$VDS = "Distributed switch name"
$VDSPG = "Port group on vDS"
$VCServer = "IP or FQDN of vCenter server"

$VMHost = Get-Cluster $Cluster | Get-VMHost | Sort MemoryGB | Select -first 1
$Datastore = $VMHost | Get-datastore | Sort FreeSpaceGB -Descending | Select -first 1
$Network = Get-VDPortgroup -VDSwitch $VDS -Name $VDSPG -Server $VCServer

# Fill out the OVF/OVA configuration parameters

# xsmall,small,medium,large,smallrc,largerc
$ovfconfig.DeploymentOption.value = "xsmall"

# IP Address
$ovfConfig.vami.vRealize_Operations_Manager_Appliance.ip0.value = "192.168.0.69"

# Gateway
$ovfConfig.vami.vRealize_Operations_Manager_Appliance.gateway.value = "192.168.0.1"

# Netmask
$ovfConfig.vami.vRealize_Operations_Manager_Appliance.netmask0.value = "255.255.255.0"

# DNS
$ovfConfig.vami.vRealize_Operations_Manager_Appliance.DNS.value = "192.168.0.30"

# vSphere Portgroup Network Mapping
$ovfconfig.NetworkMapping.Network_1.value = $Network

# IP Protocol
$ovfconfig.IpAssignment.IpProtocol.value = "IPv4"

# Timezone
$ovfconfig.common.vamitimezone.value = "Etc/UTC"

# Deploy the OVF/OVA with the config parameters
Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name $VMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
