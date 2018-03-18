
:local IcmpRateLimit
:set IcmpRateLimit "25,200:packet"

/ip firewall filter
add action=jump chain=input jump-target=icmp protocol=icmp place-before=0 comment="ICMP"
add action=jump chain=output jump-target=icmp protocol=icmp place-before=0 comment="ICMP"
add action=jump chain=forward jump-target=icmp protocol=icmp place-before=0 comment="ICMP"
add action=accept chain=icmp comment="ICMP: echo request" icmp-options=8:0-255 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: echo reply" icmp-options=0:0-255 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: time exceeded (traceroute)" icmp-options=11:0 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: host unreachable (traceroute)" icmp-options=3:1 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: port unreachable (traceroute)" icmp-options=3:3 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: net unreachable" icmp-options=3:0 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: fragmentation needed and don't fragment was set (PMTU)" icmp-options=3:4 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: destination network administratively prohibited" icmp-options=3:9 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: destination host administratively prohibited" icmp-options=3:10 limit=$IcmpRateLimit protocol=icmp
add action=accept chain=icmp comment="ICMP: communication administratively prohibited" icmp-options=3:13 limit=$IcmpRateLimit protocol=icmp
add action=drop chain=icmp comment="ICMP: default drop" protocol=icmp

/ipv6 firewall filter
add action=jump chain=input jump-target=icmp protocol=icmpv6 place-before=0 comment="ICMPV6"
add action=jump chain=output jump-target=icmp protocol=icmpv6 place-before=0 comment="ICMPV6"
add action=jump chain=forward jump-target=icmp protocol=icmpv6 place-before=0 comment="ICMPV6"
add action=accept chain=icmp comment="ICMPV6: echo request" icmp-options=128:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: echo reply" icmp-options=129:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: destination unreachable" icmp-options=1:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: packet too big" icmp-options=2:0 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: time exceeded (hop limit exceeded)" icmp-options=3:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: parameter problem" icmp-options=4:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: router advertisement" hop-limit=equal:255 icmp-options=134:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: neighbor solicitation" hop-limit=equal:255 icmp-options=135:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: neighbor advertisement" hop-limit=equal:255 icmp-options=136:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=accept chain=icmp comment="ICMPV6: redirect message" hop-limit=equal:255 icmp-options=137:0-255 limit=$IcmpRateLimit protocol=icmpv6
add action=drop chain=icmp comment="ICMPV6: default drop"
