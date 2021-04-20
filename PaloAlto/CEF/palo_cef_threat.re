NOTE: Contains URL 

CEF:\d\|Palo Alto Networks\|.*?THREAT\|(?<severity>.*?)\|.*?src=<sip> dst=<dip>\s.*?suser=((?<domain>.*?)\\)?(?<login>\S+)? duser=.*?app=(?<object>\S+)\s.*?deviceInboundInterface=(?<sinterface>\S+)? deviceOutboundInterface=(?<dinterface>\S+)?\s.*?spt=(?<sport>\d+) dpt=(?<dport>\d+)\s.*?proto=(?<protname>\S+) act=(?<command>\S+) request="(?<url>.*?)"\s
