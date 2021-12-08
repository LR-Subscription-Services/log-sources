using namespace System.Collections.Generic

$Username = 'svc_loginsight@example.com'
$LogInsightServer = 'https://loginsight.example.com:9543'
$LastRuntimeFile = 'LR_LogInsight_LastRuntime.txt'
$RuntimeFullPath = Join-Path -Path $Pwd -ChildPath $LastRuntimeFile
Try {
    [DateTime]$LastTimestamp = $(Get-Content -Path $RuntimeFullPath).split('',[System.StringSplitOptions]::RemoveEmptyEntries) -Join " "
} Catch {
    [datetime]$LastTimestamp = Get-Date
}


$MS_EVIDs = [list[string]]::new()
$MS_EVIDs.add("4624")
$MS_EVIDs.add("4625")
$MS_EVIDs.add("4776")
$MS_EVIDs.add("636")
$MS_EVIDs.add("1102")
$MS_EVIDs.add("4634")
$MS_EVIDs.add("4647")
$MS_EVIDs.add("4720")
$MS_EVIDs.add("4721")
$MS_EVIDs.add("4726")
$MS_EVIDs.add("4728")
$MS_EVIDs.add("4732")
$MS_EVIDs.add("4740")
$MS_EVIDs.add("4746")
$MS_EVIDs.add("4751")
$MS_EVIDs.add("4756")
$MS_EVIDs.add("4761")
$MS_EVIDs.add("4767")
$MS_EVIDs.add("4768")
$MS_EVIDs.add("4769")
$MS_EVIDs.add("4771")
$MS_EVIDs.add("4778")
$MS_EVIDs.add("4785")
$MS_EVIDs.add("4787")

Try {
    [pscredential] $LICred = Import-Clixml -Path (Join-Path -Path $(get-location) 'pscred_loginsight.xml')
} Catch {

    $Password = Read-Host -AsSecureString -Prompt "Enter password"
    $LICred = [pscredential]::new($Username, $Password)
    $LICred | Export-CliXml (Join-Path -Path $(get-location) 'pscred_loginsight.xml')

}


# Establish HTTP / HTTPS Definitions / Exceptions

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$PSDesktopException = @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
Add-Type $PSDesktopException
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Begin Section - Function Definition


Function New-LogInsightAuth {
    [CmdletBinding()]
    Param(
        [pscredential] $LICredential,

        [string] $Url
    )
    Begin {
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "text/plain")

        $body = "{`"username`":`"$($LICredential.Username)`",`"password`":`"$($LICredential.GetNetworkCredential().Password)`",`"provider`":`"ActiveDirectory`"}"
        write-verbose $body
    }


    Process {
        $response = Invoke-RestMethod "$Url/api/v1/sessions" -Method 'POST' -Headers $headers -Body $body
        return $response
    }

}


Function Get-LILogs {
    [CmdletBinding()]
    Param(
        [pscredential] $LICred,

        [string] $Url,

        [string] $EVID,

        [int32] $LastMs,

        [int32] $MaxRetries = 5
    )
    Begin {
        $Session = New-LogInsightAuth -LICredential $LICred -Url $LogInsightServer
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $($Session.sessionId)")
    }


    Process {
    # text/CONTAINS%20ACCOUNT%20FAILED/timestamp/LAST%20360000'"
        $RequestURL = $Url + "/api/v1/events/eventid/%3$($EVID)/timestamp/LAST`%20$($LastMs)?limit=1000&timeout=15000"
        #$RequestURL = $Url + "/api/v1/events/eventid/%3$($EVID)/?limit=1000&timeout=15000"

        Do {
            $RetryRequest = $false
            Try {
                $Response = Invoke-RestMethod -Uri $RequestURL -Headers $Headers -Method 'Get' -verbose
            } Catch {
                if($_.Exception.Response.StatusCode.value__ -eq 403) {
                    if ($RetryCounter -ge $MaxRetries) {
                        $RetryRequest = $false
                    } else {
                        $Session = New-LogInsightAuth -LICredential $LICred -Url $LogInsightServer
                        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
                        $headers.Add("Authorization", "Bearer $($Session.sessionId)")
                        $RetryCounter += 1
                        $RetryRequest = $true
                        Start-sleep -Milliseconds 250
                    }
                } elseif ($_.Exception.Response.StatusCode.value__ -eq 429) {
                    if ($RetryCounter -ge $MaxRetries) {
                        $RetryRequest = $false
                    } else {
                        $RetryCounter += 1
                        $RetryRequest = $true
                        Start-sleep -Milliseconds 250
                    }
                }               
            }
        } While ($RetryRequest)
        
        return $response
    }

}




ForEach ($MS_EVID in $MS_EVIDs) {
    write-host "Begin Collection - EVID: $($MS_EVID)"
    $Counter = 0
    [int32]$LastMsRes = $(New-TimeSpan -Start $LastTimestamp -end $(get-date)).TotalMilliseconds
    $Logs = Get-LiLogs -Url $LogInsightServer -EVID $MS_EVID -LICred $LICred -LastMs $LastMsRes
    $LogCount = $Logs.events.count
    write-host "EVID: $($MS_EVID)  Retrieved: $($LogCount)"
    ForEach ($Log in $Logs.events) {
        $Counter += 1
        $Log_EVID = $($Log.fields | Where-Object -Property name -like 'eventid' | select-object -ExpandProperty content)
        switch ($Log_EVID) {
            '4776' {
                # Regex to capture and pull additional details from raw log from LogInsight message payload
                #Logon Account:\s+(?<sname>\S+)\nSource Workstation:\s+(?<shost>\S+)\nError Code:\s(?<error_code>\S+)
             }
        }

        $OCLog = [PSCustomObject]@{
            sip = $($Log.fields | Where-Object -Property name -like 'source' | select-object -ExpandProperty content)
            vmid = $Log_EVID
            dname = $($Log.fields | Where-Object -Property name -like 'hostname' | select-object -ExpandProperty content)
            action = $($Log.fields | Where-Object -Property name -like 'task' | select-object -ExpandProperty content)
            tag1 = $($Log.fields | Where-Object -Property name -like 'channel' | select-object -ExpandProperty content)
            tag2 = $($Log.fields | Where-Object -Property name -like 'task' | select-object -ExpandProperty content)
            tag3 = $($Log.fields | Where-Object -Property name -like 'keywords' | select-object -ExpandProperty content)
            command = $($Log.fields | Where-Object -Property name -like 'task' | select-object -ExpandProperty content)
            vendorinfo = $($Log.fields | Where-Object -Property name -like 'keywords' | select-object -ExpandProperty content)
            severity = $($Log.fields | Where-Object -Property name -like 'level' | select-object -ExpandProperty content)
            fullyqualifiedbeatname = "webhookbeat_sdp_li"
            whsdp = $true
            "timestamp.epoch" = $Log.timestamp
            original_message = $Log.Text
        }
        # Submit log to OpenCollector for ingestion
        Invoke-RestMethod -Method 'post' -Uri 'http://10.149.39.90:8085/webhook' -Body ($OCLog | ConverTTo-Json) | Out-Null
        #write-host "EVID: $($MS_EVID)  Sending Log: $($Counter) of $($LogCount)"
    }
    start-sleep 1
    write-host "End Collection - EVID: $($MS_EVID)"
}

[datetime]$LastTimestamp = Get-Date
$LastTimestamp | Out-File -FilePath $RuntimeFullPath -Force