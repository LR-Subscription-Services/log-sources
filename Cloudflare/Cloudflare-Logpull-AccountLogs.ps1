# This script is developed by LogRhythm Professional Services.It downloads 
# Cloudflare logs via Logpull REST API V4 and saves into a local directory
# for SysMon to collect. 
#=========================================================================#
# Key notes: 
# 1. Cloudflare only keeps log data (Data) from 7 days ago to 1 mins ago
# 2. All data will be downloaded into ./Data folder, arranged by date
# 3. Data older than 7 days (configurable) will be purged
# 4. A temp file to record the last log timestamp will be generated during runtime.
#    You can manipluate this value for testing purpose. However,Do NOT remove it or
#    change it in prod, otherwise collection will start from 30 mins ago.
# 5. It's not recommended to change the configs in this file except for the
#    paramters mentioned in "Instructions" section.
# 6. Reduce timeRangeMins if you encounter time-out error.
# 7. Logs can be found in ./log folder and logs are kept for 7 days only.
# 8. Only 1 running instance allowed at all times. Delete pid.lock if the previous
#    instance exited with error.
# 9. Tested on PS V5.
#=========================================================================#

# Author : hong.guang@logrhythm.com             
# Version: v1.0
# Date   : 19 Jun, 2020

#=========================================================================#

# Instructions: 
# 1. Place this script in a any folder where SysMon has read permission
# 2. Update the following fields for production deployment: (Contact your
# Cloudflare admin to obtain these info)
# Start: Modified by chye.hsiang@logrhythm.com to donwnload account logs
$accID              = "Cloudflare_accountID"
$token              = "Cloudflare_AccountToken"
# End: Modified by chye.hsiang@logrhythm.com to donwnload account logs
$timeRangeMins      = 30 # Mins, time range for every retrievel, max is 60
# 3. Create a Windows Scheduled Task to run this script every 30 mins
# 4. Onboard the log data as Flat Flie (MPE Rules to be developed)
#=========================================================================#


#====================== Main Program =====================================#
Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [string]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message
    )

    $time = (Get-Date).toString("yyyy-MM-dd HH:mm:ss")
    $Line = "$time $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}


Function Download-Data {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $StartTime,

    [Parameter(Mandatory=$True)]
    [string]
    $EndTime,

    [Parameter(Mandatory=$True)]
    [string]
    $Datafile
    )
    $url = $zoneUrl + "&start=" + $StartTime + "&end=" + $EndTime
    # Start: Modified by chye.hsiang@logrhythm.com to donwnload account logs
	Write-Log -message ("REST API URL : " + $url)
	# End: Modified by chye.hsiang@logrhythm.com to donwnload accoun logs																		  
    Invoke-RestMethod -Uri $url -Headers $headers | Out-File -Append $Datafile
    Write-Log -message ("Log data between " +$StartTime+ " and " + $EndTime + 
            " saved to " + $Datafile)
    $EndTime | Out-File $posFile
    Write-Log -message ("Last message read updated to " + $EndTime)
    
}

Function Create-Folder{
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $path
    )

    If(!(test-path $path))
    {
          New-Item -ItemType Directory -Force -Path $path
    }
}

Function Create-File{
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $path
    )

    If(!(test-path $path))
    {
          New-Item -ItemType File -Force -Path $path
    }
}

# Trap for an exception during the Script
trap [Exception]
{
    if ($PSItem.ToString() -eq "ExecutionFailure")
	{
		exit 1
	}
	else
	{
		Write-Log -message $("Trapped: $_") -Level ERROR
		Write-Log -message "Aborting Operation." -Level ERROR
		exit
	}
}

#---------------------------------------------------
# Set the variables
#---------------------------------------------------
$nowTime            = Get-Date
$folderTimeFormat   = "yyyyMMdd"
$todayStr           = $nowTime.ToString($folderTimeFormat)
$scriptLogFolder    = "$PSScriptRoot\logs\"
$dataRootFolder     = "$PSScriptRoot\data"
$dataFolder         = "$PSScriptRoot\data\$todayStr-acct"
$logfile     = $scriptLogFolder+$todayStr+"-acct.log"
$posFile     = "$PSScriptRoot\cf-acct.pos"
$posFileTimeFormat  = "yyyy-MM-ddTHH:mm:ssZ"
$dataFileTFormat    = "yyyyMMddHHmmss"
$lockFile           = "$PSScriptRoot\pid-acct.lock"

# Start: Modified by chye.hsiang@logrhythm.com to donwnload account logs
$zoneUrl            = "https://api.cloudflare.com/client/v4/accounts/$accId/audit_logs?per_page=1000"
# End: Modified by chye.hsiang@logrhythm.com to donwnload account logs
$headers            = @{"Authorization" = ("Bearer " + $token);}
$dataRetentionDays  = 8 # Number of days that raws data to be kept in local drive
$logRetentionDays   = 8 # Number of days that logs to be kept in local drive
$historyDataMins    = 30 # history data if no pos file is found
$cfLogDelay         = 1 # Cloudflare requires minimum 1 mins delay in serving logs.

#---------------------------------------------------
# create files/folders required if they don't exist
#---------------------------------------------------

Create-File -path $logfile
Create-File -path $posFile
Create-Folder -path $dataFolder

#---------------------------------------------------
# Determine if this script is already running 
#---------------------------------------------------
if(test-path $lockFile){
    Write-Log -message ("Lock file is found. Exiting...")
}else{
    Create-File -path $lockFile
}

#---------------------------------------------------
# Determine start time
#---------------------------------------------------
if((Get-Content $posFile) -eq $null){
    $startTime = $nowTime.AddMinutes(-$historyDataMins)
    Write-Log -message ("Pos file is empty. Set start time to " + $startTime)
}else{
    try{
        $startTime = [datetime]::ParseExact((Get-Content $posFile), $posFileTimeFormat, $null)
        Write-Log -message ("Last message time readed from pos file " + $startTime)
        $tmpTimeDiff = New-TimeSpan -Start $startTime -End $nowTime
        if($tmpTimeDiff.TotalMinutes -gt 10080){
            # last log message is older than 7 days (10080 mins), so reset start time to 7 days ago
            $startTime = $nowTime.AddMinutes(-10079)
            Write-Log -message ("Last message time is rest to " + $startTime)
        }
        

    }catch{
        Write-Log -message ("Error found while converting time from " + (Get-Content $posFile)) -Level ERROR
        Write-Log -message ("Provide a correct timestamp in this format: " + $posFileTimeFormat)  -Level WARN
		exit
    }
}

Write-Log -message "Start downloading logs from Cloudflare..."

$startTimeStr = $startTime.ToUniversalTime().ToString($posFileTimeFormat)
$dataFolder = "$dataRootFolder\"+ $startTime.ToString($folderTimeFormat)
Create-Folder -path $dataFolder
$dataFile = $dataFolder + "\" + $startTime.ToString($dataFileTFormat) + ".log"
Create-File -path $dataFile

$timeDiff = New-TimeSpan -Start $startTime -End $nowTime


if($timeDiff.TotalMinutes -gt $historyDataMins){
    
    $endTime = $startTime.AddMinutes($timeRangeMins)

    if($nowTime -le $endTime){
        $endTimeStr = $nowTime.AddMinutes(-$cfLogDelay).ToUniversalTime().ToString($posFileTimeFormat)
        Download-Data -StartTime $startTimeStr -EndTime $endTimeStr -Datafile $dataFile
    }else{
        do{
            $endTimeStr = $endTime.ToUniversalTime().ToString($posFileTimeFormat)
            Download-Data -StartTime $startTimeStr -EndTime $endTimeStr -Datafile $dataFile

            $startTime = $endTime
            $startTimeStr = $startTime.ToUniversalTime().ToString($posFileTimeFormat)
            $dataFolder = "$dataRootFolder\"+ $startTime.ToString($folderTimeFormat)
            Create-Folder -path $dataFolder
            $dataFile = $dataFolder + "\" + $startTime.ToString($dataFileTFormat) + ".dat"
            Create-File -path $dataFile

            $endTime = $startTime.AddMinutes($timeRangeMins)

            if($nowTime -le $endTime){
                $endTimeStr = $nowTime.AddMinutes(-$cfLogDelay).ToUniversalTime().ToString($posFileTimeFormat)
                Download-Data -StartTime $startTimeStr -EndTime $endTimeStr -Datafile $dataFile
            }
            Write-Log -message "Entering sleep mode..."
            Start-Sleep -s 15
        }while($nowTime -gt $endTime)
    }

}elseif($timeDiff.TotalMinutes -le 1){
    Write-Log -message "The targte system requires minimum 1 mins delay in serving logs."
}else{
    $endTimeStr = $nowTime.ToUniversalTime().AddMinutes(-$cfLogDelay).ToString($posFileTimeFormat)
    Download-Data -StartTime $startTimeStr -EndTime $endTimeStr -Datafile $dataFile
}

Write-Log -message "Completed downloading logs from Cloudflare. "

Write-Log -message "Start archiving old data..."

$oldLogDate = $nowTime.AddDays(-$dataRetentionDays)
for($count = 1; $count -lt 15;$count++)
{
    $dataFolder = "$dataRootFolder\"+ $oldLogDate.ToString($folderTimeFormat)
    if(test-path $dataFolder){
        Remove-Item –path $dataFolder -Recurse -ErrorAction Ignore
    }
    $oldLogDate = $nowTime.AddDays(-$dataRetentionDays-$count)
}

Write-Log -message "Completed archiving old data."

Write-Log -message "Start archiving old log..."

$oldLogDate = $nowTime.AddDays(-$logRetentionDays)
for($count = 1; $count -lt 15;$count++)
{
    $oldLog = "$scriptLogFolder"+ $oldLogDate.ToString($folderTimeFormat)+".log"
    if(test-path $oldLog){
        Remove-Item –path $oldLog -ErrorAction Ignore
    }
    $oldLogDate = $nowTime.AddDays(-$logRetentionDays-$count)
}

Write-Log -message "Completed archiving old log."

Write-Log -message "Releasing lock..."

Remove-Item –path $lockFile

Write-Log -message "Lock released."