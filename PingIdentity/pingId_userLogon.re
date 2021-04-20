Common Event: User Login

^?.*\|(?<command>\w+?)\| (?<login>.*?)\| (?<sip>.*?) \|.*?\| (?<url>.*?)\| (?<object>.*?)\| (?<sinterface>.*?)\| (?<process>\w+)\| (?<tag1>.*?)\| (?<protname>.*?)\| (?<subject>.*?)\| (?<milliseconds>\d+)$

Sub Rules:
	- If tag1="failure", common event is "user logon failure"
	- If tag2="success", common event is "user logon"