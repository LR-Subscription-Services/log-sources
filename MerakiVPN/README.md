# Meraki VPN
## Problem
Prospect in POC wanted to have a VPN Dashboard that displayed (1) a list of users logged into VPN, (2) where the users were logging in from locationally, and (3) what machines the users were accessing.

## Challenge
The prospect is using Meraki Firewalls currently for Network traffic and VPN. Cisco Meraki as a supported log source type in LogRhythm currently has 34 MPE Rules associated with it, none of which classify VPN Traffic. During the course of the POC, almost all Meraki Traffic was being classified as one of two MPE Rules: Unknown request or General Information log (Catch All 4)

## Solution
LogRhythm Labs hopped in to better classify the VPN Traffic. They took the .llx logs from Meraki that focused on VPN traffic and crafted a MPE Rules I classified as “General VPN Information”.  After sorting this rule above the Catch All MPE Rule, it classified location, users, and IP addresses within the VPN logs. This allowed me to construct a dashboard listing those items the prospect requested as well as display on the Threat Activity map where in the world the users were logging in from.

## Dashboard
![](https://github.schq.secious.com/CustomerSuccess/LogSources/blob/master/MerakiVPN/merakiVpn_dashboard.png)

***
*Original Author: Emily Henriksen*