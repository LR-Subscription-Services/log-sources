# Duo
## Log Source Setup Overview
**Vendor/Product**: DuoSecurity/DuoSecurity 2FA  
**Product Type**: 2FA Auth  
**Collection Type**: Flat File Collection  
**Integration Type**: Vendor API via Python
## Integration Details
What does it do? Why was it added? In what situations would it be used?  Who would want to use this feature? 
### Installation Considerations
This integration operates via a python script that is run from a scheduled task on WindowsOS based host running a LogRhythm agent. There are several prerequisites that need to be met and considered, as listed below.
### Configuration Considerations
1. Although this collection could work from any OS that supports a Python interpreter, this guide assumes a Windows OS is used. If another OS is desired, contact the author of this document.
1. The host OS will need to have a Python interpreter installed, as well as several python modules. Python interpreters are free and available from python.org, the version of python installed matters, so stick with what is outlined in this document.
1. This integration uses a Windows scheduled task to run a python script. As a result, the script has a finite granularity based on the run interval of every 5 minutes.
1. The script pulls date/times from the vendor in a time/epoch format, but the agent ignores the timestamps. This means that every log line will be date stamped as a time of collection. The net result of this is that logs read from Duo will have 5 minute duplicate time references. Authentications will be resolvable to the nearest five minutes inside the SIEM. This is a significant deficiency and should be corrected at a later date (by modifying the python script to convert the time strings.)
1. Make sure that the customer is running LogRhythm 7.2.6 or newer. This integration will work with earlier versions of LogRhythm if the base rule regex is modified to not use metadata fields only present in 7.2.x and newer.
## Benefits
Customers/ProServ can use this document to create log source collections of DuoSecurity 2FA authentications. This document is based on a customer who uses the cloud-based DouSecurity 2FA solution which is typically housed on Amazon as cloud appliance.
## Implementation Details
### Support
LogRhythm does not support this collection mechanism, make sure the customer understands this.
### Professional Services
LogRhythm ProServ is the only intended audience of this document; please do not share it with customers/partners with managerial approval.
### Integration/Setup Steps
1. Install Python v3.x from python.org
    1. Python 2.7.x will cause the script to error out with a parse module error. If you can't use python v3, you can make this work with 2.7.x by commenting out the "from urllib.Parse import urlparse" line at the top of the script. Just keep in mind that this will break proxy support for the collection.
1. Download the duo API client from https://github.com/duosecurity/duo_client_python
1. Decompress the zip file into c:\LogRhythm
1. Run a DOS command prompt (as administrator) and change dirs to the uncompressed zip file
1. Run the following commands:  
    `pip install --requirement requirements.txt`  
    `pip install --requirement requirements-dev.txt`  
    `pip install duo_client`  
    `pip install parse`  
1. Get the LogRhythm Duo python script (filename is: logRhythmDuoAPI.py)
1. Get or create the [duo.conf](Log-Sources-and-Parsers/Duo/duo.conf) file that the script/API needs. 
1. Edit the "target" in the def main() function of the "logRhythmDuoAPI.py" script to reflect where logs get written to 
    1. Old Line:  
    `target = open(c:/Program Files/Python35/duologs/output/'+ timestr + 'Output.txt', 'a')`
    1. Change the path to something like  
    `c:/LogRhythm/duologs/output/`
1. Create MPE rules for Duo Log Source
    1. Create a flat file log source type, call it something like: "Flat File - DuoSecurity2FA"
    1. 4 rules make up this policy, here are the base regex patterns and rule names  
    Rule 001 - [Administrator Object Manipulation](https://github.schq.secious.com/CustomerSuccess/Log-Sources-and-Parsers/blob/master/Duo/duo_adminObjectManip.re)  
    Rule 002 - [Administrator Login](https://github.schq.secious.com/CustomerSuccess/Log-Sources-and-Parsers/blob/master/Duo/duo_adminLogin.re)  
    Rule 003 - [2FA User Auth](https://github.schq.secious.com/CustomerSuccess/Log-Sources-and-Parsers/blob/master/Duo/duo_2faUserAuth.re)  
    Rule 004 - [Duo Telephony Activity](https://github.schq.secious.com/CustomerSuccess/Log-Sources-and-Parsers/blob/master/Duo/duo_telephonyActivity.re)
    1. Specify the MPE rule sort order as follows:
        1. Rule 003
        1. Rule 004
        1. Rule 001
        1. Rule 002
1. Create MPE policy for this log source type, turn auto sort off.
1. In _Local Security Policy > Local Policies > Security Options_ : 
    1. Network Access: Do not allow storage of passwords and credentials for network authentication
    1. set it to _Disabled_
1. Run the Python script once manually from either the DOS command line (invoked as Administrator) or from a Python CLI shell. This is done to make sure the script runs fine on it's own.
1. Automate the collection by creating a task in the task scheduler. Make sure LR agent service account is used to execute the task (this is not required, but a good practice.)
    1. program is: python
    1. add arugments: `c:\LogRhythm\logRhythmDuoAPI.py c:\LogRhythm\duo.conf`
    ![](https://github.schq.secious.com/CustomerSuccess/LogSources/blob/master/Duo/duo_img1.jpg)  
    ![](https://github.schq.secious.com/CustomerSuccess/LogSources/blob/master/Duo/duo_img2.jpg)  
    ![](https://github.schq.secious.com/CustomerSuccess/LogSources/blob/master/Duo/duo_img3.jpg)
1. Watch the task scheduler log for the task you created to make sure it is not erroring out. Check the script output directory to make sure files are getting generated.
1. Create a flat file collection in the LR Console of uses a wildcard or directory collection of the script output directory. 
## Troubleshooting
You will likely encounter problems with this integration in one of several areas:
### Python PIP module install
If you are attempting to do step 5 and getting errors, make sure you are running those commands from a Python CLI shell, not a DOS CLI shell. Also make sure you invoke the Python CLI shell as Administrator.
### Python Script operation when called manually once from the command line
You may get errors of one kind or another in step 12. This is likely due to a syntactical error in the script during the edits of step 8. Check the script again. It is likely that the script will end up bundled with this document in a pre-edited form.
### Python script runs fine when called manually but not when either run from a scheduled task or when a user is not logged into the Windows OS.
This is due to a security feature of the WindowsOS. There are two causes for this, either step 11 was not followed (or Group Policy is undoing it), or the task (in the task scheduler) did not have the  "Run where the user is logged on or not" AND  "Run with highest privileges" selected.

***
*Original Author: Nick Ritter*