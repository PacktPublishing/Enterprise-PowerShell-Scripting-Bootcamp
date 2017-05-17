###################################################################
# Chapter 12 - Code File
###################################################################

###################################################################
# How to Create a termination file.
###################################################################
# Locally 
new-item -path "c:\temp\KILL_SERVER_SCAN.NOW" -ItemType File

# Remotely
Enter-PSSession -ComputerName POSHDEMO-SQL01
new-item -path "c:\temp\KILL_SERVER_SCAN.NOW" -ItemType File
Exit-PSSession

###################################################################
# How to Remove a termination file.
###################################################################
# Locally
Remove-Item -Path "c:\temp\KILL_SERVER_SCAN.NOW" -Force

# Remotely
Enter-PSSession -ComputerName POSHDEMO-SQL01
Remove-Item -Path "c:\temp\KILL_SERVER_SCAN.NOW" -Force
Exit-PSSession


###################################################################
# Create Several CSV Files
###################################################################
$logloc = "C:\temp\POSHScript\CSVDEMO\"
$date = (Get-Date -format "yyyyMMddmmss")
Function create-testcsv { param($servername)
    $csvfile = "$logloc\$servername" + "_" + $date + "_ScanResults.csv"
    new-item $csvfile -ItemType File -Force | Out-Null

    $csvheader = "ServerName, Classification, Other Data"
    Add-content $csvfile -Value $csvheader

    $csvcontent = "$servername, CSVTestData, This is CSV Test Data for $servername."
    Add-content $csvfile -Value $csvcontent
}
create-testcsv POSHDEMO-Server1
create-testcsv POSHDEMO-Server2
create-testcsv POSHDEMO-Server3
create-testcsv POSHDEMO-Server4
create-testcsv POSHDEMO-Server5
get-childitem $logloc

###################################################################
# How to Merging Data Results
###################################################################

$logloc = "C:\temp\POSHScript\CSVDEMO\"
$date = (Get-Date -format "yyyyMMddmmss")
$mergefile = "$logloc" + "Merged_$date.csv"
New-Item $mergefile -ItemType File | Out-Null
(get-childitem $logloc -filter "*.csv").FullName | Import-csv | Export-csv $mergefile -NoTypeInformation


