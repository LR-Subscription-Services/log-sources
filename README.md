# Log Sources
The purpose of this repository is to consolidate the log source knowledge capital that exceeds or expands upon what is natively supported in the product.

**These parsers have been migrated to Community under Shareables > Parsers**

## Process
**Never, for any reason, ever, should anyone commit a change directly against the *master* branch.**
1. Create a development branch off of the *master* branch (see naming convention standards)
1. Clone your new development branch to your local system
1. Make the desired changes/additions
1. Commit those changes (see commit standards)
1. Push those changes to origin
1. Create a Pull Request to pull your changes into *master*
1. A user with write privileges will need to review the proposed changes and merge the commit
1. At this point your development branch changes are all in *master*, but changes from other people will not be reflected in your dev branch.  To update your dev branch to match *master*, in GitHub Desktop, go to the Repository menu and select *Update From Default Branch*

## Standards
1. **Naming Convention**
No file or directory name should ever contain spaces.
	1. *Branches* - Last name of the contributor, all lower case (e.g. *talley*)
	1. *Directories* - Lead with a capital letter, followed by camelCase. (e.g. *SampleDirectoryName*). If the name contains an all-caps acronym like 'VPN' or 'IDS', that native capitalization should be maintained.
	1. *Files* - File name should maintain strict camelCase (e.g. *sampleFileName*).  Even all-caps acronyms should be ignored in favor of camelCase.  File names under each log source should contain the log source name in a prefix, followed by an underscore, before describing the individual file (e.g. *logSource_fileDescription.re*).  File names should **always** contain the appropriate suffix for the file type (e.g. *.re, .py, .sh*)
1. **Directory Structure**
	* Manufacturer (*Cisco*)
		* Device (*ASA*)
			* Collection Format (*Syslog*) - Optional; use if multiple formats exist
1. **Tabs, not Spaces** - [Seriously, always tabs](https://www.youtube.com/watch?v=SsoOG6ZeyUI&t=8s )
1. **README** - Every directory containing actual code, RegEx, or scripts should have a README.md file to introduce the contents, including any assumptions or known issues.  Log sources that were added during the initial import to build this repository will have the 'Original Author' listed in the README; this designation is not required unless the GitHub author is different than the original author.
1. **Commit Notes**
	1. *Summary* - WHAT you're changing/adding
	1. *Description* - WHY you're making changes/additions

***
Measure twice, cut once.
