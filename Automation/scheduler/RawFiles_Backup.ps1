Start-Transcript -Path "C:\Users\Public\Documents\I13_I_Vibration\logs\raw_backup.txt" -Append

Set-Variable -Name "RawFiles_Dir" -Value "C:\Users\Public\Documents\I13_I_Vibration\raw_data\"
Set-Variable -Name "Backup_Dir" -Value "\\diamproject01\diamond$\Science\I13\Vibration_Monitoring\raw_data\"

Set-Variable -Name "nrdays" -Value 20

Add-Type -assembly "system.io.compression.filesystem"

# list all directories older than $nrdays
$directories = Get-ChildItem -Path $RawFiles_Dir -Directory -recurse| where {$_.LastWriteTime -le $(get-date).Adddays(-$nrdays)}

Write-Host "Starting"

# for each directory,
foreach($dir in $directories){
    Write-Host $dir
    $source_dir = $RawFiles_Dir + $dir
    $archive_file = $RawFiles_Dir + $dir + ".zip"

    Write-Host $archive_file

    # zip directory
    [io.compression.zipfile]::CreateFromDirectory($source_dir, $archive_file)

    # move zip to S drive
    Move-Item -Path $archive_file -Destination $Backup_Dir

    $fileToCheck = $Backup_Dir + $dir + ".zip"
    # if the file has been moved, remove directory and clear bin
    if (Test-Path $fileToCheck -PathType leaf){
        Remove-Item $source_dir -Recurse
        Clear-RecycleBin -Force
    }
}

Stop-Transcript
