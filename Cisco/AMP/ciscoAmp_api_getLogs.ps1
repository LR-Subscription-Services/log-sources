#Written by Mason Vensland - ReliaQuest
#Reference Documentation - https://www.cisco.com/c/en/us/support/docs/security/amp-endpoints/201121-Overview-of-the-Cisco-AMP-for-Endpoints.html 

#Notes
#   This script is intended to be used in conjunction with Microsoft Windows Task Scheduler to run every 5 minutes. Each pull writes to its own Flat File which is later deleted. 
#   It requires the existence of the Windows curl.exe file in order to perform the API Call 

#Dynamic Variables (Change these)
    #Client ID: Enter the Client ID associated with the Cisco AMP Cloud Instance
    $clientID=''

    #API Key: Enter the API Key that was automatically generated 
    $APIKey=''
    
    #Output Directory: Enter destination for log files
    #Default: $outDir='C:\RQScripts\CiscoAMPlogs\'
    $outDir=''

    #Curl Path: Set the path to the curl executable which is used for the API pull
    #Default: $curlPath='C:\RQScripts\'
    $curlPath=''

#Static Variables - Do not change these unless you wish to change the query or log file name
    #Combined string for API URL (<ClientID:APIKey>)
    $APIString=$clientID+':'+$APIKey
    
    #Start Time Date for Log File naming
    $start=(get-date).AddMinutes(-5).ToString("yyyyMMddhhmm")
    
    #End Time Date for Log File N=naming
    $end=(get-date).ToString("yyyyMMddhhmm")
    
    #Log File Prefix
    $prefix='AMPLogs-'

    #Log File Name
    $fileName=$prefix+$start+'-'+$end+'.log'
    
    #Fully Qualified File Name
    $path=$outDir+$fileName
    
    #Start time for API Pull (last 5 minutes)
    $startTime=(get-date).AddMinutes(-5).ToString("yyyy"+'-'+"MM"+'-'+"dd"+'T'+"hh"+'\%3A'+"mm"+'\%3A00\%2B00\%3A00')

#Run API Pull
    #Run API Call - Returns log data as one line in JSON
    cd $curlPath
    $json=.\curl.exe -k https://$APIString@api.amp.sourcefire.com/v1/events?start_date=$startTime
    
    #Manipulate JSON output to make it line by line (one log per line)
    $output = $json.replace(',{"id":',"`n{`"id`":")
    
    #Output the data to Log File
    echo $output | Out-File $path

#Rotate old logs
    #Sets the amount of days to keep (Default is 1 day)
    $Daysback = "-1"
    $CurrentDate = Get-Date
    $DatetoDelete = $CurrentDate.AddDays($Daysback)

    #Deletes data older than $Daysback
    Get-ChildItem -recurse -path $outDir | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-item -Force