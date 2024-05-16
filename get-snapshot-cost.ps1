$resource_name = "<snapshot name>"

$data = Get-AzConsumptionUsageDetail -StartDate 2023-09-01 -EndDate 2023-09-30
$filteredData = $data | Where-Object { $_.InstanceName -eq $resource_name}


# Actual cost
$totalPretaxCost = ($filteredData | Measure-Object -Property PretaxCost -Sum).Sum
Write-Host "Total Actual Pretax Cost: $totalPretaxCost"


# Rounded off cost
$totalPretaxCost = [math]::Round(($filteredData | Measure-Object -Property PretaxCost -Sum).Sum, 2)
Write-Host "Total Rounded Pretax Cost: $($totalPretaxCost.ToString('F2'))"
