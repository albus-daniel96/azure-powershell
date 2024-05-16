param ($RG_Name, $VM_Name)

$VM_data = Invoke-AzVMRunCommand -ResourceGroupName $RG_Name -VMName $VM_Name -CommandId 'RunPowerShellScript' -ScriptPath 'Get Free C disk and CPU Win.ps1'
$VM_data = $VM_data.Value[0].Message | ConvertFrom-String

$data_to_csv = [PSCustomObject]@{
 "VM Name" = $VM_Name
 "RG Name" = $RG_Name
 "DiskName" = "C:Windows"
 "TotalSize" = $VM_data.P8
 "CPU_Utilization" = $VM_data.P15
 "FreeSpace" = $VM_data.P20
}

$data_to_csv | Export-Excel -Path '.\VM_Data.xlsx' -Append
