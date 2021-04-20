
filterlog:\s(?<policy>[0-9]*),[0-9]*,,[0-9]*,(?<sinterface>[0-9A-Za-z]*),(?<command>[A-Za-z]*),(?<tag1>[pass|block|reject]*),(?<tag2>[A-Za-z]*),[0-9]*,[0-9A-Za-z\s]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9A-Za-z]*,(?<protnum>[0-9]*),(?<protname>[A-Za-z0-9]*),[0-9]*,(?<sip>[A-Za-z0-9\.\:]*),(?<dip>[A-Za-z0-9\.\:]*),(?<sport>[0-9]*),(?<dport>[0-9]*)

3 subrules for <tag1>:
	- Network Allow / pass
	- Network Deny / block
	- Network Deny / reject
