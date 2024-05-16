<#
=======================================
Blob storage account, total volume, 
=======================================
#>
$date = (Get-date).ToString("MMddyyyy")
$storageaccountreport = "StorageAccount_Report_"+$date+".csv"

$sub = "<Azure subscription name>"

$storageAccounts = Get-AzStorageAccount

foreach($storageAccount in $storageAccounts){

$containers = Get-AzStorageContainer -Context $storageAccount.Context

$totalSize = 0
foreach ($container in $containers) {
    $blobs = Get-AzStorageBlob -Context $storageAccount.Context -Container $container.Name
    foreach ($blob in $blobs) {
        $totalSize += $blob.Length
    }
}

$sizeInGB = $totalSize / 1GB

$policyRules = Get-AzStorageAccountManagementPolicy -ResourceGroupName $storageAccount.ResourceGroupName -StorageAccountName $storageAccount.StorageAccountName

# Fetch and output the name of each lifecycle management rule as a list
if ($policyRules.Rules.Count -gt 0) {
    $ruleNames = $policyRules.Rules.Name
    Write-Output "Lifecycle management rule names:"
    $ruleNames | ForEach-Object {
        Write-Output "- $_"
    }
} else {
    $LifeCycleRule= "No lifecycle management rules found for the storage account."
}

$StorageAccountDetails = "" | Select-Object Name,Subscription,Location,Size_GB,Life_cycle_management_rules
$StorageAccountDetails.Name = $storageAccount.StorageAccountName
$StorageAccountDetails.Subscription = $sub
$StorageAccountDetails.Location = $storageAccount.Location
$StorageAccountDetails.Size_GB = $sizeInGB
$StorageAccountDetails.Life_cycle_management_rules=$LifeCycleRule

#Write-Output "Total data volume in the storage account $storageAccount : $sizeInGB GB"

Export-Csv -InputObject $StorageAccountDetails -path $storageaccountreport -Append -NoTypeInformation -Force
}
