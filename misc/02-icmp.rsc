/ip firewall filter
add action=jump chain=input jump-target=icmp protocol=icmp place-before=0 comment="ICMP"
add action=jump chain=output jump-target=icmp protocol=icmp place-before=0 comment="ICMP"
add action=jump chain=forward jump-target=icmp protocol=icmp place-before=0 comment="ICMP"
add action=accept chain=icmp comment="icmp echo request" icmp-options=8:0-255 limit=5k,500:packet protocol=icmp
add action=accept chain=icmp comment="icmp echo reply" icmp-options=0:0-255 limit=5k,500:packet protocol=icmp
add action=accept chain=icmp comment="icmp time exceeded (traceroute)" icmp-options=11:0 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp host unreachable (traceroute)" icmp-options=3:1 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp port unreachable (traceroute)" disabled=yes icmp-options=3:3 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp net unreachable" icmp-options=3:0 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp fragmentation needed and don't fragment was set (PMTU)" icmp-options=3:4 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp destination network administratively prohibited" icmp-options=3:9 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp destination host administratively prohibited" icmp-options=3:10 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp communication administratively prohibited" icmp-options=3:13 limit=5k/5s,2:packet protocol=icmp
add action=drop chain=icmp comment="drop all other icmp" protocol=icmp

/ipv6 firewall filter
add action=jump chain=input jump-target=icmp protocol=icmpv6 place-before=0 comment="ICMPV6"
add action=jump chain=output jump-target=icmp protocol=icmpv6 place-before=0 comment="ICMPV6"
add action=jump chain=forward jump-target=icmp protocol=icmpv6 place-before=0 comment="ICMPV6"
add action=accept chain=icmp comment="icmpv6: echo request" icmp-options=128:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: echo reply" icmp-options=129:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: destination unreachable" icmp-options=1:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: packet too big" icmp-options=2:0 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: time exceeded (hop limit exceeded)" icmp-options=3:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: parameter problem" icmp-options=4:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: router advertisement" hop-limit=equal:255 icmp-options=134:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: neighbor solicitation" hop-limit=equal:255 icmp-options=135:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: neighbor advertisement" hop-limit=equal:255 icmp-options=136:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=accept chain=icmp comment="icmpv6: redirect message" hop-limit=equal:255 icmp-options=137:0-255 limit=5k/5s,2:packet protocol=icmpv6
add action=drop chain=icmp

