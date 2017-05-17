###################################################################
# Chapter 9 - Code File
###################################################################

###################################################################
# Example On How To Get .log and .txt files from a directory
###################################################################
Get-ChildItem "c:\Program Files\" -Include *.log,*.txt -recurse

###################################################################
# Example On How To Scan .log and .txt for simple strings
###################################################################

$matches = Get-ChildItem "c:\Program Files\" -Include *.log,*.txt -recurse | select-string -pattern "Complete" -SimpleMatch
foreach ($match in $matches) {
    Write-Host "Filename: " $match.FileName
    Write-Host "Line Number: " $match.LineNumber
    Write-Host "Line Contents: " $match.Line
}

###################################################################
# Example On How To Handle File Path Exceptions
###################################################################
# Create Folder Structure to Scan
$userdrive = "c:\Temp\POSHScript\Chapter9Examples\CompanyXYZ\Milwaukee\InformationTechnologyDepartment\UserHomeDrives\UserLoginID\"
new-item $userdrive -ItemType Directory -Force
$domainuser = "$env:computername\Brenton"
New-SmbShare -name "UserData" -Path $userdrive -FullAccess $domainuser
New-PSDrive -Name H -root "\\$env:computername\Userdata" -Persist -PSProvider FileSystem
cd H:
$userFolder = "Information Technology Department\All Company Software\ISO\Microsoft\Microsoft SQL Server 2012 R2\SQL Server Update Patches\Service Pack 3\Cumulative Update 7\AutomatedWindowsInstaller\"
new-item $userFolder -ItemType Directory -Force

#Scan Folder Struture
$directory = "c:\Temp\POSHScript\Chapter9Examples\CompanyXYZ\"
$errors = @()
get-childitem $directory -recurse -ErrorAction SilentlyContinue -ErrorVariable +errors
if ($errors) {
    foreach ($err in $errors) {
        if ($err.Exception -like "*Could not find a part of the path*") {
            $filepath = ($err.Exception).ToString().split("'")[1]
            Write-Host "Error Accessing Path: `"$filepath`" may be over 248 Characters."
        }
        if ($err.Exception -like "*is denied.*") {
            $filepath = ($err.Exception).ToString().split("'")[1]
            Write-Host "Error Accessing Path: `"$filepath`" Access Is Denied."
        }
    }
}
# Remove Mapped Drive and Share
cd c:
Remove-PSDrive -Name H -Force
Remove-SmbShare -name "UserData" -Force


##################################################################
# Example On How To Create a Scan Function Leveraging Search Exclusions
###################################################################

function scan-directory { param($directory)
    $errors = @()
    $content = get-childitem $directory -Include $include -Exclude $exclude -recurse -ErrorAction SilentlyContinue -ErrorVariable +errors | select-string -Pattern $findword -SimpleMatch -ErrorAction SilentlyContinue

    if ($errors) {
        foreach ($err in $errors) {
            if ($err.Exception -like "*Could not find a part of the path*") {
                $filepath = ($err.Exception).ToString().split("'")[1]
                Write-Host "Error Accessing Path: `"$filepath`" may be over 248 Characters."
            }
            if ($err.Exception -like "*is denied.*") {
                $filepath = ($err.Exception).ToString().split("'")[1]
                Write-Host "Error Accessing Path: `"$filepath`" Access Is Denied."
            }
        }
    }
    foreach ($match in $content) {
        Write-Host "Filename: " ($match.FileName).Trim()
        Write-Host "Line Number: " $match.LineNumber
        Write-Host "Line Contents: " ($match.Line).Trim()
    }
}

$include = "*.xml","*.txt"
$exclude = ""
$findword = "Complete"
scan-directory "c:\Windows\System32\"

$include = "*.xml","*.txt"
$exclude = "*hppcl3-pipelineconfig.xml*","Cleanup.xml"
$findword = "Complete"
scan-directory "c:\Windows\System32\"


