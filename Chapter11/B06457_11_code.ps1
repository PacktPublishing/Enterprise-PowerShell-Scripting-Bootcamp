###################################################################
# Chapter 11 - Code File
###################################################################

###################################################################
# Example On how to match different patterns
###################################################################
"192.168.12.24" -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
"00:A0:F8:12:34:56" -match "^([0-9a-f]{2}:){5}[0-9a-f]{2}$"
"brent@testingdomain.com" -match "^.+@[^\.].*\.[a-z]{2,}$"
"4000-4000-4000-4000" -match "^\d{4}-\d{4}-\d{4}-\d{4}$"
"123-45-6789" -match "^\d{3}-\d{2}-\d{4}$"

###################################################################
# Example On How Dynamically Build a Regular expression
###################################################################
$myarray = “administrator”,“password”,“username”
$searchRegex = '(?i)^.*(' + (($myarray| % {[regex]::escape($_)}) –join "|") + ').*$'
"This String has Administrators in it." -match $searchRegex
"This PASSWORD is not secure." -match $searchRegex
"TheUsernames are not written." -match $searchRegex
$searchRegex.tostring()

###################################################################
# Example On How Regular Expressions are faster than Multiple Arrays
###################################################################

$files = (Get-ChildItem c:\Windows\System32 -Recurse -ErrorAction SilentlyContinue).Name
1..8 | % { $files += $files }
Write-host "Total Number of Files to Analyze: " $files.count

###################################################################
# Example On How Regular Expressions are faster than Multiple Arrays
###################################################################

$types = ".xml",".exe",".dll"
$filefound = 0 
$time1 = Measure-Command {
    foreach ($type in $types) {
        foreach ($file in $files) {
            if ($file -like "*$type") { $filefound += 1 }
        }
    }
}
Write-host "Total Number of Found Files $filefound"
$filefound = 0 
$searchRegex = '(?i)^.*(' + (($types | foreach {[regex]::escape($_)}) –join "|") + ')$'
$time2 = Measure-Command {
        foreach ($file in $files) {
            if ($file -match $searchRegex) { $filefound += 1 }
        }
}
Write-host "Total Number of Found Files $filefound"
$time1
$time2
$timediff = ($time1 - $time2).TotalSeconds
Write-host "Total Difference in Speed: $timediff Total Seconds"
