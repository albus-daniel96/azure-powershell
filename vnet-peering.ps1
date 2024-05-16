$virtualNetwork1 = Get-AzVirtualNetwork -Name <vnet-1 name> -ResourceGroupName <vnet-1 rg name>
$virtualNetwork2 = Get-AzVirtualNetwork -Name <vnet-2 name> -ResourceGroupName <vnet-2 rg name>

Add-AzVirtualNetworkPeering `
  -Name myVirtualNetwork1-myVirtualNetwork2 `
  -VirtualNetwork $virtualNetwork1 `
  -RemoteVirtualNetworkId $virtualNetwork2.Id

Add-AzVirtualNetworkPeering `
  -Name myVirtualNetwork2-myVirtualNetwork1 `
  -VirtualNetwork $virtualNetwork2 `
  -RemoteVirtualNetworkId $virtualNetwork1.Id
