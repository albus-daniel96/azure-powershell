$date = Get-Date -Format "MMddyyyy"
$storageAccountReport = "StorageAccount_Report.csv"
$sub = "<subscription name>"
$storageAccounts = Get-AzStorageAccount

$result = foreach ($storageAccount in $storageAccounts) {
    $containers = Get-AzStorageContainer -Context $storageAccount.Context -ErrorAction SilentlyContinue

    $totalSize = 0
    foreach ($container in $containers) {
        $blobs = Get-AzStorageBlob -Context $storageAccount.Context -Container $container.Name -ErrorAction SilentlyContinue
        foreach ($blob in $blobs) {
            $totalSize += $blob.Length
        }
    }

    $sizeInGB = $totalSize / 1GB

    $policyRules = Get-AzStorageAccountManagementPolicy -ResourceGroupName $storageAccount.ResourceGroupName -StorageAccountName $storageAccount.StorageAccountName -ErrorAction SilentlyContinue

    if ($policyRules -and $policyRules.Rules.Count -gt 0) {
        $ruleNames = $policyRules.Rules.Name -join ","
    } else {
        $ruleNames = "No lifecycle management rules found for the storage account."
    }

    [PSCustomObject]@{
        Name = $storageAccount.StorageAccountName
        Subscription = $sub
        Location = $storageAccount.Location
        Size_GB = $sizeInGB
        Life_cycle_management_rules = $ruleNames
    }
}

if ($result) {
    $result | Export-Csv -Path $storageAccountReport -NoTypeInformation -Force
} else {
    "No storage accounts found."
}
