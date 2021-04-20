Common Event: Detected Malware Activity 
Classification: Security:Malware

^.*?cs1=(?<threatid>.*?)\scs2Label=malopDetectionType\scs2=(?<vmid>.*?)\s.*?cs3=(?<objecttype>.*?)\s.*?cs4=(?<objectname>.*?)cs5Label.*?cs5=(?<subject>.*?)deviceCustom.*?cs6=(?<url>.*?)$

SAMPLE LOG:
Apr 1 07:28:00 customer-20170323-1-t syslogLogger CEF:0|Cybereason|Cybereason|2016.12.4|Malop|Malop Updated|10|cs1Label=malopId cs1=11.2410556438743392178 cs2Label=malopDetectionType cs2=HIJACKED_PROCESS cs3Label=malopActivityType cs3=MALICIOUS_INFECTION cs4Label=malopSuspect cs4=injected (ldgetserviceperformanceinfo.exe > chrome.exe) cs5Label=malopKeySuspicion cs5=Malicious By Code Injection deviceCustomDate1Label=malopCreationTime deviceCustomDate1=Jan 25 2017, 17:17:08 UTC deviceCustomDate2Label=malopUpdateTime deviceCustomDate2=Apr 01 2017, 07:28:00 UTC cn1Label=affectedMachinesCount cn1=14 cn2Label=affectedUsersCount cn2=14 cs6Label=linkToMalop cs6=https://customer-ui.cybereason.net:8443/#/malop/MalopProcess/maliciousByCodeInjection/11.24105564387...