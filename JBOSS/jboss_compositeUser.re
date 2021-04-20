v1:
(?=(?s).*?"composite")"user"\s+:\s+"(?<login>[^"]+)",\s+"domainUUID"\s+:\s+"(?<domain>[^"]+)",\s+"access"\s+:\s+"(?<protname>[^"]+)",\s+"remote-address"\s+:\s+"<sip>/(?:(?!\k'sip')<snatip>"|[^"]+"),\s+"success"\s+:\s+(?<tag1>false|true),\s+"ops"\s+:\s+\[\{\s+"(operation)"\s+:\s+"(?<command>[^"]+)",\s+"address"\s+:\s+\[\],\s+"<tag2>

v2:
(?=(?s).*?"composite")(?s)"user"\s+:\s+"(?<login>[^"]+)",\s+"domainUUID"\s+:\s+"(?<domain>[^"]+)",\s+"access"\s+:\s+"(?<protname>[^"]+)",\s+"remote-address"\s+:\s+"<sip>/(?:(?!\k'sip')<snatip>"|[^"]+"),\s+"success"\s+:\s+(?<tag1>false|true),\s+"ops"\s+:\s+\[\{\s+"(operation)"\s+:\s+"(?<command>[^"]+)",\s+"address"\s+:\s+\[\],\s+"<subject>"\s:.*?"server-group"\s+:\s+"<group>"
