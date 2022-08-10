# AUTHOR:    Fabian
# SOURCE:    https://blog.spaps.de/mikrotik-routeros-wireguard-dynamic-dns-endpoint-refresh/
# DESC:      This script checks if the peer endpoint address still matches the dns name and if not,
#            updates to the latest ip address of the DNS name.
# KEYWORDS:  ros7, wireguard, vpn, fqdn, refresh
 
:local wgPeerComment
:local wgPeerDns

:set wgPeerComment "my.endpoint.tld"
:set wgPeerDns "my.endpoint.tld"

:if ([interface wireguard peers get number=[find comment="$wgPeerComment"] value-name=endpoint-address] != [resolve $wgPeerDns]) do={
  interface wireguard peers set number=[find comment="$wgPeerComment"] endpoint-address=[/resolve $wgPeerDns]
}
