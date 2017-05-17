###################################################################
# Chapter 7 - Code File
###################################################################

###################################################################
# Example On How To Query the local Disks
###################################################################
get-disk

###################################################################
# Example On How To Query the local Disks using WMI
###################################################################
Get-WmiObject -class win32_logicaldisk

###################################################################
# Example On How To Determine Disk Type
###################################################################
$disks = get-wmiobject win32_logicaldisk
Foreach ($disk in $disks) {
    $driveletter = $disk.DeviceID
    switch ($disk.DriveType) {
        0 { $type = "Type Unknown." }
        1 { $type = "Doesn't have a Root Directory." } 
        2 { $type = "Removable Disk (e.g. USB Key)" } 
        3 { $type = "Local Disk (e.g. Hard Drive / USB hard drive / Virtual drive mount)" } 
        4 { $type = "Network Drive (e.g. Mapped Drive)" } 
        5 { $type = "Compact Disk (e.g. CD/DVD Drive)" } 
        6 { $type = "RAM Disk (e.g. Memory Mapped Drive / PE OS Drive)" } 
        default { $type = "Unable To Determine Drive Type!" }
    }
    Write-host "Drive: $driveletter | Disk Type: $type"
}

###################################################################
# Example On How To Convert Disk Size to Megabytes and Gigabytes
###################################################################
$disks = get-wmiobject win32_logicaldisk
Foreach ($disk in $disks) {
  $driveletter = $disk.DeviceID
  $sizeMB = [System.Math]::Round(($disk.size / 1MB),2)
  $sizeGB = [System.Math]::Round(($disk.size / 1GB),2)
  Write-host "$driveletter | Size (in MB): $sizeMB | Size (in GB): $sizeGB"
}


###################################################################
# Example On How To Convert Disk Units / Values 
###################################################################
function measure-diskunit { param($diskspace)
    switch ($diskspace) {
      {$_ -gt 1PB} { return [System.Math]::Round(($_ / 1PB),2),"PB" }
      {$_ -gt 1TB} { return [System.Math]::Round(($_ / 1TB),2),"TB" }
      {$_ -gt 1GB} { return [System.Math]::Round(($_ / 1GB),2),"GB" }
      {$_ -gt 1MB} { return [System.Math]::Round(($_ / 1MB),2),"MB" }
      {$_ -gt 1KB} { return [System.Math]::Round(($_ / 1KB),2),"KB" }
      default { return [System.Math]::Round(($_ / 1MB),2),"MB" }
    }
}
measure-diskunit 868739194880123456
measure-diskunit 868739194880123
measure-diskunit 868739194880
measure-diskunit 868739194
measure-diskunit 868739

###################################################################
# Example On How To Evaluate Disk Information
###################################################################
function measure-diskunit { param($diskspace)
    switch ($diskspace) {
      {$_ -gt 1PB} { return [System.Math]::Round(($_ / 1PB),2),"PB" }
      {$_ -gt 1TB} { return [System.Math]::Round(($_ / 1TB),2),"TB" }
      {$_ -gt 1GB} { return [System.Math]::Round(($_ / 1GB),2),"GB" }
      {$_ -gt 1MB} { return [System.Math]::Round(($_ / 1MB),2),"MB" }
      {$_ -gt 1KB} { return [System.Math]::Round(($_ / 1KB),2),"KB" }
      default { return [System.Math]::Round(($_ / 1MB),2),"MB" }
    }
}

$disks = get-wmiobject win32_logicaldisk
Foreach ($disk in $disks) {
    $driveletter = $disk.DeviceID
    $freespace = $disk.FreeSpace
    $size = $disk.Size
  
    if ($freespace -lt 1) { $freespace = "0" }
    if ($size -lt 1) { $size = "0" }
  
    $freetype = measure-diskunit $freespace
    $convFreeSpc = $freetype[0]
    $funit = $freetype[1]
  
    $sizetype = measure-diskunit $size
    $convsize = $sizetype[0]
    $sunit = $sizetype[1]

    switch ($disk.DriveType) {
        0 { $type = "Type Unknown." }
        1 { $type = "Doesn't have a Root Directory." } 
        2 { $type = "Removable Disk" } 
        3 { $type = "Local Disk" } 
        4 { $type = "Network Drive" } 
        5 { $type = "Compact Disk" } 
        6 { $type = "RAM Disk" } 
        default { $type = "Unable To Determine Drive Type!" }
    }

    write-host "Drive $driveletter | Drive Type: $type | Size: $convsize $sunit  | Freespace: $convFreeSpc $funit"

}

