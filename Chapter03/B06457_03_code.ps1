###################################################################
# Chapter 3 - Code File
###################################################################

###################################################################
# Example On How To Get the Contents in an XML file
###################################################################

[xml] $xml = get-content "C:\temp\POSHScript\Answers.xml"
$xml

###################################################################
# Example On How To Get the Contents of an XML file and Read Tags
###################################################################
[xml] $xml = get-content "C:\temp\POSHScript\Answers.xml"
$ports = $xml.GetElementsByTagName("ports")
$ports | Select Name, Port

###################################################################
# Example On How To Use Dot Notation with the previous code
###################################################################
$ports.Name
$xml.ScriptAnswers.Ports.Name

###################################################################
# Example On How To Read from and XML File
###################################################################
# Answer File Location
$xmlfile = "c:\temp\POSHScript\Scan_Answers.xml"
Function read-xmltag { param($xmlanswers, $xmlextract)
    # Validate that the XML file still exists
    $test = test-path $xmlanswers
    if (!$test) { 
        Write-Error "$xmlanswers not found on the system. Select any key to exit!"
        # Stop the Script for reading the Error Message
        PAUSE
        # Exit the Script
        exit
    }
    # Read XML Data
    [xml] $xml = (get-content $xmlanswers)
    return $xml.GetElementsByTagName("$xmlextract")
}
# Determine Features of Script
$logging = (read-xmltag $xmlfile "verboselog").id
$scanDisks = (read-xmltag $xmlfile "scndisks").id
$scanSchTasks = (read-xmltag $xmlfile "scnschtsks").id
$scanProcess = (read-xmltag $xmlfile "scnproc").id
$scanServices = (read-xmltag $xmlfile "scnsvcs").id
$scanSoftware = (read-xmltag $xmlfile "scnsoft").id
$scanProfiles = (read-xmltag $xmlfile "scnuprof").id
$scanFeatures = (read-xmltag $xmlfile "scnwfeat").id
$scanFiles = (read-xmltag $xmlfile "scnfls").id
$scanWinUpdates = (read-xmltag $xmlfile "scnwupd").id
#Display Features
Write-host "Script Scanning Settings: Verbose Logging: $logging | Scan Disks: $scanDisks | Scan Scheduled Tasks: $scanSchTasks | Scan Processes: $scanProcess | Scan Services: $scanServices | Scan Software: $scanSoftware | Scan Profiles: $scanProfiles | Scan Features: $scanFeatures | Scan Files: $scanFiles | Scan Windows Updates: $scanWinUpdates"

# Intentional Wrong Answer File Path to Display Error
read-xmltag "C:\Temp\POSHScript\DOES_NOT_EXIST.xml" "scndisks"
