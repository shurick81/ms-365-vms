$disks = Get-Disk | ? { $_.PartitionStyle -eq 'RAW' } | sort Number

$letters = 70..89 | ForEach-Object { [char]$_ }
$count = 0

foreach ($disk in $disks) {
    $driveLetter = $letters[$count].ToString()
    $disk | 
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $driveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "data[$count]" -Confirm:$false -Force;
    $count++
}