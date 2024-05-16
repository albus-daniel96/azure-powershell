$VMs = Get-AzVM
$vmOutput = $VMs | ForEach-Object {
    [PSCustomObject]@{
        "VM RG" = $_.ResourceGroupName
        "VM Type" = $_.Name
        "VM Location" = $_.Location
        "VM Size" = $_.HardwareProfile.VmSize 
        "VM OS" = -join ($_.StorageProfile.ImageReference.offer," ", $_.StorageProfile.ImageReference.sku)
        "VM NIC" = $_.NetworkProfile.NetworkInterfaces.Id.split('/')[-1]
        "VM ProvisioningState" = $_.ProvisioningState
    }
}
$vmOutput | Export-Excel -Path '.\vms-report.xlsx'
