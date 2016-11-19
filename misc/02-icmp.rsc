add action=accept chain=icmp comment="icmp echo request" icmp-options=8:0-255 limit=5k,500:packet protocol=icmp
add action=accept chain=icmp comment="icmp echo reply" icmp-options=0:0-255 limit=5k,500:packet protocol=icmp
add action=accept chain=icmp comment="icmp time exceeded (traceroute)" icmp-options=11:0 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp host unreachable (traceroute)" icmp-options=3:1 limit=5k/5s,2:packet protocol=icmp
# disable icmp packets type 3 with code 3
# See http://blacknurse.dk/ for details
# Blacknurse is a low bandwidth ICMP attack that
# is capable of doing denial of service to well known firewalls
add action=accept chain=icmp comment="icmp port unreachable (traceroute)" disabled=yes icmp-options=3:3 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp net unreachable" icmp-options=3:0 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp fragmentation needed and don't fragment was set (PMTU)" icmp-options=3:4 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp destination network administratively prohibited" icmp-options=3:9 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp destination host administratively prohibited" icmp-options=3:10 limit=5k/5s,2:packet protocol=icmp
add action=accept chain=icmp comment="icmp communication administratively prohibited" icmp-options=3:13 limit=5k/5s,2:packet protocol=icmp
add action=drop chain=icmp comment="drop all other icmp" protocol=icmp
add chain=forward place-before=0 protocol=icmp action=jump jump-target=icmp comment="process icmp"
add chain=input place-before=0 protocol=icmp action=jump jump-target=icmp comment="process icmp"
