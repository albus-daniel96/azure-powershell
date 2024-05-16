using namespace Microsoft.Azure.Commands.Management.Storage.Models

$date = (Get-date).ToString("MMddyyyy")
$filesharereport = "FileShare_Report_"+$date+".csv"
$sub = "CDO Data Lake"

$StorageAccounts = Get-AzStorageAccount


function Get-AzStorageShareStatistics {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]$ShareName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSStorageAccount]$StorageAccount,

        [Parameter(ValueFromPipeline)]
        [string]$StorageAccountName
    )
    process {
        if ($StorageAccountName -eq $null) {
            $StorageAccountName = $StorageAccount.Name
        }

        $Path = @(
            $StorageAccount.Id
            "/fileServices/default/shares/$ShareName"
            '?api-version=2021-04-01&$expand=stats'
        ) -join ''

        $response = Invoke-AzRestMethod -Path $Path
        $result = ($response.content | ConvertFrom-Json).properties
        $result | Add-Member -NotePropertyName "ShareName" -NotePropertyValue $ShareName -Force
        $result | Add-Member -NotePropertyName "StorageAccountName" -NotePropertyValue $StorageAccountName -Force
        [PSCustomObject]$result
    }
}

$StorageAccounts = Get-AzStorageAccount

foreach($StorageAccount in $StorageAccounts){

$storageAccountName = $StorageAccount.StorageAccountName

# Get the list of file shares
$fileShares = Get-AzStorageShare -Context $storageAccount.Context

# Iterate through each file share and retrieve the statistics
foreach ($fileShare in $fileShares) {
    $shareName = $fileShare.Name
    $sharedetails = Get-AzStorageShareStatistics -ShareName $shareName -StorageAccount $storageAccount -StorageAccountName $storageAccountName | Select-Object -ExcludeProperty ShareName, StorageAccountName, PSTypeName, NoteProperty, PSTypenames, Length, Count
    $shareusageGB = $sharedetails.shareUsageBytes / 1GB
    $lastmodified_date = $fileShare.ShareProperties.LastModified.DateTime
    $quota = $sharedetails.shareQuota

    $FileShareDetails = "" | Select-Object StorageAccount_Name,FileShare_Name,Subscription,Location,Usage_GB,Quota_GB,Last_Modified_Date

    $FileShareDetails.StorageAccount_Name = $storageAccountName
    $FileShareDetails.FileShare_Name = $shareName
    $FileShareDetails.Subscription = $sub
    $FileShareDetails.Location = $StorageAccount.Location
    $FileShareDetails.Usage = $shareusageGB
    $FileShareDetails.Quota = $quota
    $FileShareDetails.Last_Modified_Date = $lastmodified_date


    Export-Csv -InputObject $FileShareDetails -path $filesharereport -Append -NoTypeInformation -Force

}

}
