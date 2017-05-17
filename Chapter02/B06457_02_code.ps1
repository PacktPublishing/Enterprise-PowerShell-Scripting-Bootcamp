###################################################################
# Chapter 2 - Code File
###################################################################


###################################################################
# Example On How To Create a Sample Comment Block
###################################################################

<#
.SYNOPSIS
This is a server discovery script which will scan different server components to determine
the current configuration.

.DESCRIPTION
This script will scan processes, Windows services, scheduled tasks, server features, disk information,
registry, and files for pertinent server information.

Author: Brenton J.W. Blawat / Packt Publishing / Author / email@email.com
Revision: 2.1a - Initial Release of Script / 6-22-2018
Revision: 2.5 - Paul Brandes / Company XYZ / Consultant / email@company.com / 11-21-2018
R2.5 details: Updated script to support systems still running PowerShell 2.0.

.PARAMETER SDD
This script requires a server side decryptor as a parameter to the script.

.EXAMPLE
powershellscript.ps1 /SDD "ServerSideDecryptor"

.NOTES
You must have administrative rights to the server you are scanning. Certain functions will not work properly
without running the script as system or administrator.
#>

###################################################################
# Example On How To Create a LOG File
###################################################################
$date = (Get-Date -format "yyyyMMddmmss")
$compname = $env:COMPUTERNAME
$logname = $compname + "_" + $date + "_ServerScanScript.log"
$scanlog = "c:\temp\logs\" + $logname 
new-item -path $scanlog -ItemType File -Force

###################################################################
# Example On How To Create a CSV File
###################################################################
$date = (Get-Date -format "yyyyMMddmmss")
$compname = $env:COMPUTERNAME
$logname = $compname + "_" + $date + "_ScanResults.csv"
$scanresults = "c:\temp\logs\" + $logname
new-item -path $scanresults -ItemType File -Force

# Add Content Headers to the CSV File
$csvheader = "ServerName, Classification, Other Data"
Add-Content -path $scanresults -Value $csvheader

###################################################################
# Example On How To Register the Event Source for an Event Log
###################################################################
New-EventLog –LogName Application –Source "WindowsServerScanningScript" -ErrorAction SilentlyContinue
 

#########################################################################
### This logging mechanism will log items to an error log or add items into the CSV File
#########################################################################
function log { param($string, $scnlg, $evntlg)
    # If Y is populated in the second position, add to log file.
    if ($scnlg -like "Y") { 
        Add-content -path $scanlog -Value $string
    }
    # If Y is populated in the third position, Log Item to Event Log As well
    if ($evntlg -like "Y") {
        write-eventlog -logname Application -source "WindowsServerScanningScript" -eventID 1000 -entrytype Information -message "$string"
    }
    # If there are no parameters specified, write to the data collection file (CSV)
    if (!$scnlg) {
       $content = "$env:COMPUTERNAME,$string"
       Add-Content -path $scanresults -Value $content
    }
    # Verbose Logging
    write-host $string
}

$date = Get-Date
log "Starting WindowsServerScanningScript at $date ..." "Y" "Y"
log "Writing a message to the Event Log Only." "N" "Y"
log "ScriptStart,$date"


