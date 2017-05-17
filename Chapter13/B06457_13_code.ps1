###################################################################
# Chapter 13 - Code File
###################################################################

<#
.SYNOPSIS
This is a server discovery script which will scan different server components to determine
the current configuration.

.DESCRIPTION
This script will scan processes, Windows services, scheduled tasks, server features, disk information,
registry, and files for pertinent server information.

Author: Brenton J.W. Blawat / Packt Publishing / Author / email@email.com

.PARAMETER RTD
This script requires a run time decryptor as a parameter to the script.

.EXAMPLE
powershellscript.ps1 /RTD "Run Time Decryptor"

.NOTES
You must have administrative rights to the server you are scanning. Certain functions will not work properly
without running the script as system or administrator.#>
param($RTD)

if (!$RTD) { exit }

####################
# Answer File Logic
####################
Function read-xmltag { param($xmlextract)
    return $xml.GetElementsByTagName("$xmlextract")
}

$xmlfile = "$PSScriptRoot\Scan_Answers.xml"
$test = test-path $xmlfile
if (!$test) { 
    Write-Error "$xmlfile not found on the system. Select any key to exit!"
    PAUSE
    exit
}
[xml] $xml = get-content $xmlfile
#Remove-Item $xmlfile -force


####################
# Decryption Logic
####################
Add-Type -AssemblyName System.Security
function Decrypt-String { param($Encrypted)
   
   if($Encrypted -is [string]){
      $Encrypted = [Convert]::FromBase64String($Encrypted)
   }

   $r = new-Object System.Security.Cryptography.RijndaelManaged
   $pass = [System.Text.Encoding]::UTF8.GetBytes($pass)
   $salt = [System.Text.Encoding]::UTF8.GetBytes($salt)
   $init = [Text.Encoding]::UTF8.GetBytes($init) 
   
   $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 50000).GetBytes(32)
   $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash($init)[0..15]

   $d = $r.CreateDecryptor()
   $ms = new-Object IO.MemoryStream @(,$Encrypted)
   $cs = new-Object Security.Cryptography.CryptoStream $ms,$d,"Read"
   $sr = new-Object IO.StreamReader $cs

   try {
       $result = $sr.ReadToEnd()
       $sr.Close()
       $cs.Close()
       $ms.Close()
       $r.Clear()
       Return $result
   }
   Catch {
       Write-host "Error Occurred Decrypting String: Wrong String Used In Script."
   }
}

####################
# Function to Create RegEx
####################
function create-SearchRegEx { param($list)
    if (!$list) { $list = "No_Input_Provided_For_List_Item" }
    $RegEx = '(?i)^.*(' + (($list | % {[regex]::escape($_)}) –join "|") + ').*$'
    return $regex
}

####################
# Function to Decode Strings
####################
function decode-string { param($string)
    $encbytes = [System.Convert]::FromBase64String($string)
    $string = [System.Text.Encoding]::Unicode.GetString($encbytes)
    return $string
}

####################
# Populate Script Variables
####################

# System Configuration
$ssd = "LAAyAGwAdQBRAG8AZABMAEwAJgA"
$afd = (read-xmltag "afd") | Select id
$encpass = $ssd + $afd.id + $rtd
$pass = decode-string $encpass
$salt = (read-xmltag "salt") | % { decode-string $_.id }
$init = (read-xmltag "init") | % { decode-string $_.id }

# Logging Settings
$logloc = (read-xmltag "logloc") | Select id
$verboselog = (read-xmltag "verboselog") | Select id
$filelog = (read-xmltag "filelog") | Select id
$evntlog = (read-xmltag "evntlog") | Select id
$csvunc = (read-xmltag "csvunc") | Select id

# Enable / Disable Features
$scanDisks = (read-xmltag "scndisks") | Select id
$scanSchTasks = (read-xmltag "scnschtsks") | Select id
$scanProcess = (read-xmltag "scnproc") | Select id
$scanServices = (read-xmltag "scnsvcs") | Select id
$scanSoftware = (read-xmltag "scnsoft") | Select id
$scanProfiles = (read-xmltag "scnuprof") | Select id
$scanFeatures = (read-xmltag "scnwfeat") | Select id
$scanFiles = (read-xmltag "scnfls") | Select id

# Search Locations
$scnloc = (read-xmltag "scnloc") | Select id

# Kill File Location
$killfile = (read-xmltag "killfile") | Select id

# Search Extensions
$srextlist = @()
$srext = (read-xmltag "srext") | % { $srextlist += "*" + $_.id }

# File Search Data
$srterms = read-xmltag "srterm" | % { decrypt-string $_.id }
$srtermsRegEx = create-SearchRegEx $srterms

# File Ignore list
$flign = (read-xmltag "flign") | Select id
$flignRegEx = create-SearchRegEx $flign.id

# Search Ignore List
$srign = (read-xmltag "srign") | Select id
$sringRegEx = create-SearchRegEx $srign.id

# Built-in User List
$blst = (read-xmltag "blst") | Select id
$blstRegEx = create-SearchRegEx $blst.id



####################
# Create the Log Files
####################
$date = (Get-Date -format "yyyyMMddmmss")
$compname = $env:COMPUTERNAME
$logloc = $logloc.id
$scanlog = "$logloc\$compname" + "_" + $date + "_ServerScanScript.log"
new-item $scanlog -ItemType File -Force | Out-Null

# Create the CSV File
$scnresults = "$logloc\$compname" + "_" + $date + "_ScanResults.csv"
$csvheader = "ServerName, Classification, Other Data"
new-item $scnresults -ItemType File -Force | Out-Null
Add-content $scnresults -Value $csvheader

####################
# Create the Event Log
####################
if ($evntlog -eq "True") { New-EventLog –LogName Application –Source "WindowsServerScanningScript" -ErrorAction SilentlyContinue }
 
####################
# Create the Logging Function
####################
function log { param($string, $scnlg, $evntlg)
    if ($filelog.id -eq "True") {
          if ($scnlg -like "Y") { Add-content $scanlog -Value $string }
    }
    if ($evntlog.id -eq "True") {
         if ($evntlg -like "Y") { write-eventlog -logname Application -source "WindowsServerScanningScript" -eventID 1000 -entrytype Information -message "$string" }
    }
    if (!$scnlg) {
       $content = "$env:COMPUTERNAME,$string"
       Add-Content $scnresults -Value $content
    }
    if ($verboselog.id -eq "True") { write-host $string }
}

####################
# Start of the Script
####################
$date = (Get-Date -format "yyyyMMddmmss")
log "Starting Windows Server Scanning Script at $date ..." "Y" "Y"
log "ScriptStart,$date"

####################
# Check for Kill File
####################
function check-kill {
    if (test-path $killfile.id) {
        $date = (Get-Date -format "yyyyMMddmmss")
        log "Kill File Detected at $date. Terminating Script." "Y" "Y"
        log "KillFile, Kill File Detected at $date.. Terminating Script"
        copy-item -Path $scnresults -Destination $csvunc.id -Force
        copy-Item -Path $scanlog -Destination $csvunc.id -Force
        exit
    }
}

####################
# Disk Scanning
####################
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
function scan-disks {
    check-kill
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
        log "DiskConfiguration, Drive $driveletter | Drive Type: $type | Size: $convsize $sunit  | Freespace: $convFreeSpc $funit"
    }
}

####################
# Scheduled Task Scanning
####################
function scan-schtasks {
    check-kill
    $schtasks = Get-ScheduledTask
    foreach ($Task in $schtasks) {
        $tskUser = $Task.Principal.UserId
        if($tskUser -eq $null) { $tskuser = "SYSTEM" }
        if (!($tskUser -match $blstRegEx)) {
             $tskname = ($task.TaskName).replace(","," ")
             $tskpath = $task.TaskPath
             log "ScheduledTsksData, Scheduled task with the name of $tskname in the location of $tskpath is running as $tskuser"
        }
    }
}

####################
# Process Scanning
####################
function scan-process {
    check-kill
    $processes = Get-WmiObject win32_process
    foreach ($process in $processes) {
        $procuser = $process.GetOwner().User
        if (!($procuser -match $blstRegEx)) {
            $procname = $process.Name
            $procdom = $process.GetOwner().Domain
            $procuser = $process.GetOwner().User
            log "WindowsProcessData, $procname is running with the $procdom\$procuser account."
        }
    }
}

####################
# Windows Services Scanning
####################
function scan-services {
    check-kill
    $service = get-wmiobject win32_service
    foreach ($service in $services) {
        $svcAuthUser = $service.StartName
        if (!($svcAuthUser -match $blstRegEx)) {
            $svcdisplay = $service.DisplayName
            log "WindowsServicedata, Service with $svcdisplay name is running with $svcAuthUser account."
        }
    }
}

####################
# Software Scanning
####################
function scan-software {
    check-kill
    $RegLocations = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    foreach ($reg in $RegLocations) {
        $softwareKeys = get-ItemProperty $Reg | Select DisplayName | Sort DisplayName
        foreach ($software in $softwareKeys) {
            if ($software.DisplayName -ne $null) { 
                $value = "InstalledSoftware," + $software.DisplayName 
                log $value
            }
        }
    }
    $progpaths = "\Program Files\","\Program Files (x86)\"
    $disks = (Get-WmiObject win32_logicaldisk | where {$_.DriveType -eq "3"}).DeviceID
    foreach ($disk in $disks) {
        foreach ($progpath in $progpaths) {
            check-kill
            $progfile = $disk + $progpath
            $test = test-path $progfile
            if ($test) {
                $files = Get-ChildItem -file $progfile -Recurse | where {$_.FullName -like "*.exe"} | Select Fullname
                foreach ($file in $files) {
                    $productName = (get-itemproperty $file.FullName).VersionInfo.ProductName
                    if (!$productName) { $productName = "Product Name n/a" }
                
                    $productVersion = (get-itemproperty $file.FullName).VersionInfo.ProductVersion
                    if (!$productVersion) { $productVersion = "Product Version n/a"}
                    $value = "InstalledSoftware," + $file.Fullname + " | Name: $productName | Version: $productVersion"
                    log $value
                }
            }
        }
    }
}

####################
# Profile Scanning Function
####################
function scan-profiles {
    check-kill
    $profiles = get-wmiobject Win32_UserProfile
    foreach ($profile in $profiles) {
        $currentdate = Get-Date
        $lastusetime = $profile.LastUseTime
        $lastusetime = [Management.ManagementDateTimeConverter]::ToDateTime($lastusetime)
        $age = [math]::Round(($currentdate - $lastusetime).TotalDays)
    
        $sid = $profile.SID 
        Try {
            $usersid = New-Object System.Security.Principal.SecurityIdentifier("$SID")
            $username = $usersid.Translate( [System.Security.Principal.NTAccount]).Value
        }
        Catch {
            log "There was an error translating SID value $sid to a username. Account may not exist." "Y"
            $username = "(Deleted Account)"
        }
        log "UserProfileData, User with name $username and SID $sid last logged in $lastusetime. ($age Days Old)"
    } 
}

####################
# Windows Features Scanning
####################
function scan-features {
    check-kill
    $crntFeatures = Get-wmiobject win32_serverfeature -ErrorAction SilentlyContinue -ErrorVariable err
    if ($err) { log "ServerFeatureInfo, Cannot get server feature information from WMI. System may not be a server or access is denied to WMI." }
    foreach ($feature in $crntFeatures) {
        $featurename = $feature.Name
        log "ServerFeatureInfo, $featurename feature is installed on the system."
    }
}

####################
# File Scanning 
####################
function scan-directory {
    $errors = @()
    foreach ($directory in $scnloc) {
        check-kill
        $content = get-childitem $directory.id -Include $srextlist -recurse -ErrorAction SilentlyContinue -ErrorVariable +errors | select-string -Pattern $srtermsRegEx -ErrorAction SilentlyContinue
        if ($errors) {
            foreach ($err in $errors) {
                if ($err.Exception -like "*Could not find a part of the path*") {
                    $filepath = ($err.Exception).ToString().split("'")[1]
                    log "FileScanData, Error Accessing Path: `"$filepath`" may be over 248 Characters."
                }
                if ($err.Exception -like "*is denied.*") {
                    $filepath = ($err.Exception).ToString().split("'")[1]
                    log "FileScanData, Error Accessing Path: `"$filepath`" Access Is Denied."
                }
            }
        }
        foreach ($match in $content) {
            $filename = ($match.Path).Trim()
            if (!($filename -match $flignRegEx)) {
                $lineno = $match.LineNumber
                $linecontents = (($match.Line).Trim()).Replace(",","")
                log "FileScanData, String match found in file named $filename with the line number of $lineno and the line contents of $linecontents."
            }
        }
    }
}

if ($scanDisks.id -eq "True") { scan-disks }
if ($scanSchTasks.id -eq "True") { scan-schtasks }
if ($scanProcess.id -eq "True") { scan-process }
if ($scanServices.id -eq "True") { scan-services }
if ($scanSoftware.id -eq "True") { scan-software }
if ($scanProfiles.id -eq "True") { scan-profiles }
if ($scanFeatures.id -eq "True") { scan-features }
if ($scanFiles.id -eq "True") { scan-directory }

$date = (Get-Date -format "yyyyMMddmmss")
log "Windows Server Scanning Script completed execution at $date" "Y" "Y"
log "Scriptend,$date"
copy-item -Path $scnresults -Destination $csvunc.id -Force
copy-Item -Path $scanlog -Destination $csvunc.id -Force


# Starting the Scanning Script from Command Line
# Commented out to avoid script looping.
# powershell.exe -executionPolicy bypass -noexit -file "c:\temp\ScanningScript.ps1" "AAZwAmAE4AMgAoAFEAVAAhAFAA"