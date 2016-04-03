-- Generates a list of all hosts incl. ip addresses, respective subnets and FQDN
--
-- LONG_DESC: 
-- This query will return a list of all hosts together with
-- their associated ip addresses. Additionally each line is
-- prefixed with the subnet that's associated to the corresponding
-- ip addres. The output can be used to create a set of address
-- or access control lists to be imported onto network devices
-- such as a set of routers or firewalls.
--
-- USAGE:
-- No options available for this query, just run it
--
-- Your SQL statement would go below this line:

select concat("HOST","-",subnets.name,".",dns.name,".",domains.name) fqdn,
       INET_NTOA(interfaces.ip_addr) ip
from   interfaces,
       dns,
       domains,
       subnets,
       hosts
where  interfaces.host_id = hosts.id
and    dns.domain_id = domains.id
and    hosts.primary_dns_id = dns.id
and    subnets.id = interfaces.subnet_id
and    subnets.name NOT IN ('EXCLUDEDSUBNET')
order by interfaces.ip_addr
