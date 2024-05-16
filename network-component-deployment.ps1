$resource_group = "RG02"
$location = "South Central US"
$frontendSubnet1 = New-AzVirtualNetworkSubnetConfig -Name frontendSubnet -AddressPrefix "10.0.1.0/24"
$frontendSubnet2 = New-AzVirtualNetworkSubnetConfig -Name frontendSubnet -AddressPrefix "10.1.1.0/24"
$Vnet1 = "VnetONE"
$Vnet2 = "VnetTWO"
$publicIpName1 = "connectvm1"
$publicIpName2 = "connectvm2"

# Creating a new resource group
New-AzResourceGroup -Name $resource_group -Location $location

# Creating a new virtual network. ONE
$virtualNetwork1 = New-AzVirtualNetwork -Name $Vnet1 -ResourceGroupName $resource_group -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $frontendSubnet1
$virtualNetwork1 | Set-AzVirtualNetwork

# Creating a new virtual network. TWO 
$virtualNetwork2 = New-AzVirtualNetwork  -Name $Vnet2  -ResourceGroupName $resource_group  -Location $location  -AddressPrefix "10.1.0.0/16"  -Subnet $frontendSubnet2
$virtualNetwork2 | Set-AzVirtualNetwork

# Vnet Peering
Add-AzVirtualNetworkPeering `
  -Name myVirtualNetwork1-myVirtualNetwork2 `
  -VirtualNetwork $virtualNetwork1 `
  -RemoteVirtualNetworkId $virtualNetwork2.Id

Add-AzVirtualNetworkPeering `
  -Name myVirtualNetwork2-myVirtualNetwork1 `
  -VirtualNetwork $virtualNetwork2 `
  -RemoteVirtualNetworkId $virtualNetwork1.Id

# Network security group
$rule1 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

$rule2 = New-AzNetworkSecurityRuleConfig -Name web-rule -Description "Allow HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resource_group -Location $location -Name `
    "NSG-FrontEnd" -SecurityRules $rule1,$rule2

# Public IP 
$ip1 = @{
    Name = $publicIpName1
    ResourceGroupName = $resource_group
    Location = $location
    Sku = 'Standard'
    AllocationMethod = 'Static'
    IpAddressVersion = 'IPv4'
    Zone = 2
}
New-AzPublicIpAddress @ip1

$ip2 = @{
    Name = $publicIpName2
    ResourceGroupName = $resource_group
    Location = $location
    Sku = 'Standard'
    AllocationMethod = 'Static'
    IpAddressVersion = 'IPv4'
    Zone = 2
}
New-AzPublicIpAddress @ip2

# Creating first virtual machine - ONE
New-AzVm `
    -ResourceGroupName $resource_group `
    -Name 'VM01' `
    -Location $location `
    -VirtualNetworkName $virtualNetwork1 `
    -SubnetName $frontendSubnet1 `
    -SecurityGroupName $nsg `
    -PublicIpAddressName $publicIp1 `
    -OpenPorts 80,3389

# Creating first virtual machine - TWO
New-AzVm `
    -ResourceGroupName $resource_group `
    -Name 'VM02' `
    -Location $location `
    -VirtualNetworkName $virtualNetwork2 `
    -SubnetName $frontendSubnet2 `
    -SecurityGroupName $nsg `
    -PublicIpAddressName $publicIp2 `
    -OpenPorts 80,3389
