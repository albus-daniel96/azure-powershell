#Get the storage account:
$stg_account = Get-AzStorageAccount -ResourceGroupName "<rg-name>" -Name "<stg account name>"

#Get storage account keys:
$stg_account_keys = Get-AzStorageAccountKey -ResourceGroupName "<rg-name>" -Name "<stg account name>"

#Setting a storage account context:
$ctx = New-AzStorageContext -StorageAccountName "<stg account name>" -StorageAccountKey $stg_account_keys.Value[0] -Protocol Https

# Writing to the storage account:
Set-AzStorageBlobContent -File Report.csv -Container "reports" -Blob "AutoReport" -Context $ctx

------------------------------
EXTRA
------------------------------
##Selecting the first storage account key:
$stg_account_keys.Value[0]


----------------------------------
Automation account run book code:
----------------------------------
try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$data = Get-AzVM
$data | Out-File -FilePath Report.csv

#Get the storage account:
$stg_account = Get-AzStorageAccount -ResourceGroupName "<stg account name>" -Name "<stg account name>"

#Get storage account keys:
$stg_account_keys = Get-AzStorageAccountKey -ResourceGroupName "<stg account name>" -Name "<stg account name>"

#Setting a storage account context:
$ctx = New-AzStorageContext -StorageAccountName "csg10032001f18fa349" -StorageAccountKey $stg_account_keys.Value[0] -Protocol Https

# Writing to the storage account:
Set-AzStorageBlobContent -File Report.csv -Container "reports" -Blob "AutoReport01.csv" -Context $ctx -Force
