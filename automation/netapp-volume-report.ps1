Get-AzResource | Where-Object {$_.ResourceType -like 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'} `
| Get-AzNetAppFilesVolume | Select-Object @{Name='ShortName'; Expression={$_.Name.split('/')[2]}}, @{Name='SizeGiB';`
Expression={$_.UsageThreshold / 1024 / 1024 / 1024}},`
@{Name='ConsumedGiB'; Expression={[math]::Round($((Get-AzMetric -ResourceId $_.Id -MetricName 'VolumeLogicalSize' `
-StartTime $(get-date).AddMinutes(-15) -EndTime $(get-date) -TimeGrain 00:5:00 -WarningAction SilentlyContinue `
| Select-Object -ExpandProperty data | Select-Object -ExpandProperty Average) `
| Measure-Object -average).average / 1024 / 1024 / 1024, 2)}} | Format-Table | Out-File .\netapp-volume-data.csv
