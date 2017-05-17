###################################################################
# Chapter 8 - Code File
###################################################################

###################################################################
# Example On How To Query Installed Windows Features (2008 R2 and Up)
###################################################################
get-WindowsFeature | where {$_.Installed -eq $true} | Select DisplayName, InstallState, Parent

###################################################################
# Example On How To Query Installed Windows Features (2008 R2 and Under; PowerShell 2.0)
###################################################################
get-wmiobject win32_serverfeature | select ID, Name, ParentID

###################################################################
# Example On How To Coorelate Feature IDs to Names
###################################################################
[xml] $frxml = Get-Content ".\ServerFeatureIDs.xml"
$featRoleTable = $frxml.GetElementsByTagName("feature")
$crntFeatures = Get-wmiobject win32_serverfeature
foreach ($feature in $crntFeatures) {
    $featurename = $feature.Name
    $featureparentID = $feature.ParentID
    if ($featureparentID) {
        $featureparentName = ($featRoleTable | where {$_.ID -eq $featureparentID}).Name
        Write-host "The $featurename feature has the parentID of $featureparentID. Parent Name: $featureparentName."
    }
}


###################################################################
# Example On How To Scan for Registry for Application Names
###################################################################
$RegLocations = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
foreach ($reg in $RegLocations) {
    $softwareKeys = get-ItemProperty $Reg | Select DisplayName | Sort DisplayName
    foreach ($software in $softwareKeys) {
        if ($software.DisplayName -ne $null) { Write-host "Software Found: " $software.DisplayName }
    }
}

###################################################################
# Example On How To Scan for Program Files on each disk
###################################################################
$progpaths = "\Program Files\","\Program Files (x86)\"
$disks = (Get-WmiObject win32_logicaldisk | where {$_.DriveType -eq "3"}).DeviceID
foreach ($disk in $disks) {

    foreach ($progpath in $progpaths) {
        $progfile = $disk + $progpath
        $test = test-path $progfile

        if ($test) {
            $files = Get-ChildItem -file $progfile -Recurse | where {$_.FullName -like "*.exe"} | Select Fullname

            foreach ($file in $files) {
                $productName = (get-itemproperty $file.FullName).VersionInfo.ProductName
                if (!$productName) { $productName = "Product Name n/a" }
                
                $productVersion = (get-itemproperty $file.FullName).VersionInfo.ProductVersion
                if (!$productVersion) { $productVersion = "Product Version n/a"}

                Write-host $file.Fullname " | Name: $productName | Version: $productVersion"
            }
        }
    }
}