Set-ExecutionPolicy  RemoteSigned -Scope Process
$WINrar= "C:\Program Files\WinRAR\rar.exe"
$CurrentDate = get-date -Format dd.MM.yyyy
$Path_Net_Drive = "\\backupserver\Backup_powershell\" +$env:COMPUTERNAME
$Now= Get-Date
$Log_Path ="\\backupserver\Backup_powershell\Logs\"+$env:COMPUTERNAME
$Log_Name =$CurrentDate+"_"+$env:COMPUTERNAME

#Проверка пути и создание 
Function CheckPath ($Path) {
$Path_Exists = Test-Path -Path $Path
if ($Path_Exists -eq $False) 
        {
            New-Item $Path -type directory
        }
}

CheckPath $Log_Path | Out-Null
CheckPath $Path_Net_Drive | Out-Null

Start-Transcript -Path $Log_Path\$Log_Name.log -append
Add-PSSnapin Windows.Serverbackup -ErrorAction SilentlyContinue 

$policy = New-WBPolicy 
$target = New-WBBackupTarget -NetworkPath $Path_Net_Drive
 
Add-WBBareMetalRecovery -Policy $policy
Add-WBSystemState -Policy $policy
Add-WBVolume -Policy $policy -Volume (Get-WBVolume -CriticalVolumes)
Set-WBVssBackupOptions -Policy $policy -VssCopyBackup
Add-WBBackupTarget -Policy $policy -Target $target
Start-WBBackup -Policy $policy

if ((Get-WBSummary).LastBackupResultHR -eq 0){
Write-Host "Резервное копирование завершено"
}
else {
Write-Host "Резервное копирование не выполнено. Подробности:"
Write-Host "$error"
}

Rename-Item $target\WindowsImageBackup "BMRRECOVERY_$CurrentDate" | Out-Null
Stop-Transcript