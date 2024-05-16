$subs = Get-AzSubscription 
$sub_id = $subs.Id
for ($j = 0; $j -le $sub_id.Length-1; $j++)
{
 $context = Get-AzSubscription -SubscriptionId $sub_id[$j] 
 Set-AzContext $context 
 $All_VMs = Get-AzVM

 for ($i = 0; $i -le $All_VMs.Length-1; $i++)
 { 
  $VM_data = Get-AzVM -ResourceGroupName $All_VMs[$i].ResourceGroupName -Name $All_VMs[$i].Name -Status
  if($VM_data.Statuses[1].Code -eq "PowerState/running"){
     if(($VM_data.OsName).Contains("Windows"))
      {
        .\Calling_Win.ps1 -RG_Name $All_VMs[$i].ResourceGroupName -VM_Name $All_VMs[$i].Name

      }
     else{
        .\Calling_lin.ps1 -RG_Name $All_VMs[$i].ResourceGroupName -VM_Name $All_VMs[$i].Name
      }
  } 
 }
}

