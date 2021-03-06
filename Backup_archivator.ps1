$ErrorActionPreference = "stop"
#Указываем путь до архиватора
$WINrar = "C:\Program Files\WinRAR\rar.exe"
#Считываем текущую дату
$CurrentDate = get-date -Format dd.MM.yyyy
#Указываем путь до папки с бэкапами
$BackupPath = "C:\Backup_powershell\"
#Указываем путь до логов
$Log_Path ="C:\Backup_powershell\Logs\ARH_LOG"
$StoreBackup_Period=1
$Now=Get-Date

Start-Transcript -Path $Log_Path\$CurrentDate.log -append
#Функция удаления старых бэкапов
Function RemoveOldBackup ($Path,$Extention, $CountDays){
$LastWrite = $Now.AddDays(-$CountDays)
$FoundFiles = Get-ChildItem $Path -Include $Extention -Recurse | Where{$_.CreationTime -le "$LastWrite"}
    if ($FoundFiles -ne $NULL)
        {
            Foreach ($File in $FoundFiles)
                {
                     Remove-Item $File.FullName | Out-Null
                }
        }
}

#архивирование бэкапов
 $arh = Get-ChildItem  $BackupPath  -Filter "*BMRRECOVERY*" -Recurse | ?{$_.PSiSContainer} | %  {$_.FullName}
foreach ($file in $arh) 
{
    if ($file -ne $NULL)
        {
             $path = "$file"
             &$WINrar a -r -t -ep1 -DF "$path.rar"  "$path"| Write-Host
         }
else {break}
}
RemoveOldBackup $BackupPath "*.rar" $StoreBackup_Period
Stop-Transcript