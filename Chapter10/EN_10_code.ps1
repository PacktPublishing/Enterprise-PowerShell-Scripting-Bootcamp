###################################################################
# Chapter 10 - Code File
###################################################################

###################################################################
# Example On Measure the Ping Command
###################################################################

measure-command { ping localhost }

###################################################################
# Example On Measuring Windows Speed
###################################################################
$time1 = measure-command {
    1..10000 | % { 
                write-host "Number $_" 
                # Get the contents of C:\Windows\
                $contents = Get-ChildItem c:\windows\
                }
}

$time2 = measure-command {
    1..10000 | % { 
                # Get the contents of C:\Windows\system32\
                $contents = Get-ChildItem c:\windows\
                }
}
$time1
$time2
$timediff = ($time1 - $time2).TotalSeconds
Write-host "Total Difference in Speed: $timediff Total Seconds"

###################################################################
# Example On Measuring Windows Speed
###################################################################
$verbose = $true
function log { if ($verbose) { write-host $_ } }

$time1 = measure-command {
    1..10000 | % { 
                log "Number $_" 
                # Get the contents of C:\Windows\
                $contents = Get-ChildItem c:\windows\
                }
}

$time2 = measure-command {
    1..5000 | % { 
                log "Log $_" 
                # Get the contents of C:\Windows\
                $contents = Get-ChildItem c:\windows\
                }
                $verbose = $false
                Write-host "Running Folder Scanning Operation..."

    1..5000 | % { 
                log "Number $_" 
                # Get the contents of C:\Windows\
                $contents = Get-ChildItem c:\windows\
                }
                Write-host "Folder Scanning Operation Complete."
}

$time1
$time2
$timediff = ($time1 - $time2).TotalSeconds
Write-host "Total Difference in Speed: $timediff Total Seconds"

###################################################################
# Example On Measuring Write-Progress Speed
###################################################################

$time1 = measure-command {
    1..10000 | % {
                $attempt = $_
                $perComplete = [math]::truncate(($attempt/10000)*100)
                write-progress -Activity "Looping Retrieval of Contents of c:\Windows" -Status "$attempt of 10000." -PercentComplete $perComplete
                # Get the contents of C:\Windows\
                $contents = Get-ChildItem c:\windows\
                }
}

$time2 = measure-command {
    1..10000 | % { 
                # Get the contents of C:\Windows\
                $contents = Get-ChildItem c:\windows\
                }
}
$time1
$time2
$timediff = ($time1 - $time2).TotalSeconds
Write-host "Total Difference in Speed: $timediff Total Seconds"


###################################################################
# Example On How to Setup a Data Set for a Switch Statement
###################################################################
$dlls = 0
$exes = 0
$xmls = 0
$extensions = @()
$contents += ((Get-ChildItem "c:\windows\System32\" -include "*.xml","*.dll","*.exe" -Recurse -ErrorAction SilentlyContinue) | Select Name)
foreach ($item in ($contents.Name)) { 
    $sline = $item.split(".").length
    $extensions += '.' + $item.split(".")[$sline-1]
}
1..13 | % { $extensions += $extensions }
Write-host "Total number of Extensions: " $extensions.count


###################################################################
# Example On How to Setup a Data Set for a Switch Statement
###################################################################
$time1 = measure-command {
    foreach ($extension in $extensions) {
        # Determine the file types
        if ($extension -like "*.xml") { $xmls += 1 }
        if ($extension -like "*.exe") { $exes += 1 }
        if ($extension -like "*.dll") { $dlls += 1 }
    }
}
# Reset Count
$dlls = 0
$exes = 0
$xmls = 0
$time2 = measure-command {
    foreach ($extension in $extensions) {
        # Determine the file types
        switch($extension) {
            ".dll" { $dlls += 1 }
            ".exe" { $exes += 1 }
            ".xml" { $xmls += 1 }
            default { } #do nothing
        }
    }                
}


$time1
$time2
$timediff = ($time1 - $time2).TotalSeconds
Write-Host "Total Number of Counted DLL files $dlls"
Write-host "Total Number of Counted EXE files $exes"
Write-host "Total Number of Counted XML files $xmls"
Write-host "Total Difference in Speed: $timediff Total Seconds"

