NOTE: Does NOT contain URL

CEF:\d\|Palo Alto Networks\|.*?TRAFFIC\|(?<severity>.*?)\|.*?src=<sip> dst=<dip>\s.*?suser=((?<domain>.*?)\\)?(?<login>\S+)? duser=.*?app=(?<object>\S+)\s.*?deviceInboundInterface=(?<sinterface>\S+)? deviceOutboundInterface=(?<dinterface>\S+)?\s.*?spt=(?<sport>\d+) dpt=(?<dport>\d+)\s.*?proto=(?<protname>\S+) act=(?<command>\S+)\s.*?in=(?<bytesin>\d+) out=(?<bytesout>\d+).*?PacketsReceived=(?<packetsin>\d+) (\S*)?PacketsSent=(?<packetsout>\d+)
