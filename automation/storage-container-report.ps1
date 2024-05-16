# Define the storage account details
$sub = "<Azure subscription Name>"
$containerReport = "Container_Report_"+$date+".csv"
$storageAccounts = Get-AzStorageAccount

foreach($storageAccount in $storageAccounts){

# Get the storage account context
$storageAccountContext = $storageAccount.Context

# Get the list of containers
$containers = Get-AzStorageContainer -Context $storageAccountContext

# Loop through each container
foreach ($container in $containers) {

    # Get the latest blob uploaded to the container
    $latestBlob = Get-AzStorageBlob -Container $container.Name -Context $storageAccountContext | Sort-Object -Property LastModified -Descending | Select-Object -First 1

    # Output the details of the latest blob
    if ($latestBlob) {
       $BlobName = $($latestBlob.Name)
        $BlobSize = $($latestBlob.Length)
        $BolbSize_GB = $BlobSize / 1GB
        $Last_Modified = $($latestBlob.LastModified)
    } else {
        $BlobName = "N/A"
        $BolbSize_GB = "N/A"
        $Last_Modified = "N/A"
    }

$ContainerDetails = "" | Select-Object StorageAccount_Name,Container_Name,Subscription,Location,Blob_Name,Size_Container_GB,Last_Modified_Date
$ContainerDetails.StorageAccount_Name = $storageAccount.StorageAccountName
$ContainerDetails.Container_Name = $container.Name
$ContainerDetails.Subscription = $sub
$ContainerDetails.Location = $storageAccount.Location
$ContainerDetails.Blob_Name = $BlobName
$ContainerDetails.Size_Container_GB = $BolbSize_GB
$ContainerDetails.Last_Modified_Date=$Last_Modified

#Write-Output "Total data volume in the storage account $storageAccount : $sizeInGB GB"

Export-Csv -InputObject $ContainerDetails -path $containerReport -Append -NoTypeInformation -Force
}
}
