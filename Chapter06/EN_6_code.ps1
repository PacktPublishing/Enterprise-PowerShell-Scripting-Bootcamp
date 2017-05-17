###################################################################
# Chapter 6 - Code File
###################################################################

###################################################################
# Example On How To Get the Scheduled Tasks
###################################################################
get-scheduledtask 
(get-scheduledtask).count

###################################################################
# Example On How To create a Scheduled Task Trigger
###################################################################
$schTrigger = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At "23:00"
$schTrigger


###################################################################
# Example On How To create a Scheduled Task Action
###################################################################
$schAction = New-ScheduledTaskAction -Execute "Calc.exe"
$schAction

###################################################################
# Example On How To Create a Scheduled Task Setting Set
###################################################################
$schSettingSet = New-ScheduledTaskSettingsSet -DisallowDemandStart -Hidden -DisallowHardTerminate
$schSettingSet

###################################################################
# Example On How To Create a Scheduled Task
###################################################################
$schAction = New-ScheduledTaskAction -Execute "Calc.exe"
$schTrigger = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At "23:00"
$schSettingSet = New-ScheduledTaskSettingsSet -DisallowDemandStart -Hidden -DisallowHardTerminate
$schTask = New-ScheduledTask -Action $schAction -Trigger $schTrigger -Settings $schSettingSet
$schTask
$schTask.Triggers

###################################################################
# Example On How To Create Scheduled Tasks
###################################################################
$schAction = New-ScheduledTaskAction -Execute "Calc.exe"
$schTrigger = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At "23:00"
$schTask = New-ScheduledTask -Action $schAction -Trigger $schTrigger
Register-ScheduledTask -TaskName "Start Calc Daily at 11PM" -InputObject $schTask
Register-ScheduledTask -TaskName "Start Calc Daily at 11PM_DeleteMe" -InputObject $schTask
Unregister-ScheduledTask -TaskName "Start Calc Daily at 11PM_DeleteMe" -Confirm:$false
Get-ScheduledTask | where {$_.TaskName -like "Start Calc Daily at 11PM*"}

###################################################################
# Example On How To Change an Existing Scheduled Task
###################################################################
$schAction1 = New-ScheduledTaskAction -Execute "Calc.exe"
$schAction2 = New-ScheduledTaskAction -Execute "Notepad.exe"
Set-ScheduledTask -TaskName "Start Calc Daily at 11PM" -Action $schAction1,$schAction2

###################################################################
# Example On How To Retrieve Run As Values
###################################################################
$users = @()
$schtasks = Get-ScheduledTask
foreach ($Task in $schtasks) {
    $tskUser = $Task.Principal.UserId 
    switch ($Task.Principal.UserId) {
        "NETWORK SERVICE" { $continue = "Skip User" }
        "LOCAL SERVICE" { $continue = "Skip User" }
        "SYSTEM" { $continue = "Skip User"}
        "$null" { $continue = "Skip User" }
        default { $continue = "Report User" }
    }
    if ($continue -eq "Report User") {  
    
        $users += $tskUser
    }
}
$users | Get-Unique