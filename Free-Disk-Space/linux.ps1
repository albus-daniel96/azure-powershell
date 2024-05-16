param ($RG_Name, $VM_Name)

$Lin_VM_data = Invoke-AzVMRunCommand -ResourceGroupName $RG_Name -VMName $VM_Name -CommandId 'RunShellScript' -ScriptPath 'Get Free root disk and CPU Lin.sh'
$Lin_VM_data = $Lin_VM_data.Value[0].Message | ConvertFrom-String

$Lin_data_to_csv = [PSCustomObject]@{
 "VM Name" = $VM_Name
 "RG Name" = $RG_Name
 "DiskName" = "\dev\root"
 "TotalSize" = $Lin_VM_data.P13
 "CPU_Utilization" = $Lin_VM_data.P4
 "FreeSpace" = $Lin_VM_data.P15
}

$Lin_data_to_csv | Export-Excel -Path '.\VM_Data.xlsx' -Append
