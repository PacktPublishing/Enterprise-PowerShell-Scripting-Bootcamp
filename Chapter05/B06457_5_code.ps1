###################################################################
# Chapter 5 - Code File
###################################################################

###################################################################
# Example On How To Get Service Information
###################################################################
Get-service –DisplayName "Windows Audio"
Get-service –DisplayName "Windows Audio" –RequiredServices
(Get-service –DisplayName "Windows Audio").Status 


###################################################################
# Example On How To Stop and Start Services
###################################################################
stop-service –DisplayName "Windows Audio"
(Get-service –DisplayName "Windows Audio").Status
start-service –DisplayName "Windows Audio"
(Get-service –DisplayName "Windows Audio").Status


###################################################################
# Example On How To Change the Starup Type of a Windows service
###################################################################
(get-wmiobject win32_service –filter "DisplayName='Windows Audio'").StartMode
stop-service –name "Audiosrv"
set-service –name "Audiosrv" –startup "Manual"
(get-wmiobject win32_service –filter "DisplayName='Windows Audio'").StartMode
set-service –name "Audiosrv" –startup "Automatic"
(get-wmiobject win32_service –filter "DisplayName='Windows Audio'" ).StartMode
Start-service –name "Audiosrv"


###################################################################
# Example On How To Change the Description of a Windows Service
###################################################################
$olddesc = (get-wmiobject win32_service –filter "DisplayName='Windows Audio'").description
$olddesc
stop-service –DisplayName "Windows Audio"
Set-service –name "Audiosrv" –Description "My New Windows Audio Description."
(get-wmiobject win32_service –filter "DisplayName='Windows Audio'").description
Set-service –name "Audiosrv" –Description $olddesc
(get-wmiobject win32_service –filter "DisplayName='Windows Audio'").description
start-service –DisplayName "Windows Audio"

###################################################################
# Example On How To Query a Windows Service for the Startup User
###################################################################
$service = get-wmiobject win32_service | where {$_.DisplayName -like "Windows Audio"}
$servicedisplay = $service.DisplayName
$serviceAuthUser = $service.StartName
write-host "Service with $servicedisplay name is running with $serviceAuthUser account."


###################################################################
# Example On How To Search for A Process
###################################################################
$process = get-process powersh*
$process
get-process -id $process.id


###################################################################
# Example On How To View the File Versions of A Process
###################################################################
$process = get-process powersh*
get-process -id $process.id –FileVersionInfo | format-table -AutoSize


###################################################################
# Example On How To View the Modules of a Process
###################################################################
$processes = Get-WmiObject -class win32_process | where {$_.Name -like "powersh*"}
foreach ($process in $processes) {
    $procname = $process.Name
    $procdom = $process.GetOwner().Domain
    $procuser = $process.GetOwner().User
    Write-host "$procname is running with the $procdom\$procuser account."
}


###################################################################
# Example On How To Start a Notepad Process
###################################################################
start-process -FilePath notepad.exe
$process = get-process notepad*


###################################################################
# Example On How To Start and stop a Notepad Process
###################################################################
start-process -FilePath notepad.exe
$process = get-process notepad*
stop-process -ID $process.id


###################################################################
# Example On How To Scan Logged on Users on a system
###################################################################
$users = @()
$processes = Get-WmiObject win32_process
foreach ($process in $processes) {
    $procuser = $process.GetOwner().User
    switch ($process.GetOwner().User) {
        "NETWORK SERVICE" { $continue = "Skip User" }
        "LOCAL SERVICE" { $continue = "Skip User" }
        "SYSTEM" { $continue = "Skip User"}
        "$null" { $continue = "Skip User" }
        default { $continue = "Report User" }
    }
    if ($continue -eq "Report User") {  
    
        $users += $procuser
    }
}
$users | Get-Unique

###################################################################
# Example On How To Convert a SID to Usernames
###################################################################
$sid = "S-1-5-18"
$usersid = New-Object System.Security.Principal.SecurityIdentifier("$SID")
$usersid.Translate( [System.Security.Principal.NTAccount]).Value

###################################################################
# Example On How To Convert a LastUseTime to User-Friendly Formats
###################################################################
$profile = get-wmiobject Win32_UserProfile | Where {$_.SID -eq "S-1-5-18"}
$lastusetime = $profile.LastUseTime
$lastusetime
[Management.ManagementDateTimeConverter]::ToDateTime($lastusetime)

###################################################################
# Example On How To Scan Profiles on a System
###################################################################
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
        Write-Host "There was an error translating SID value $sid to a username. Account may not exist."
        $username = "(Deleted Account)"
    }
    Write-host "User with name $username and SID $sid last logged in $lastusetime. ($age Days Old)"

}

