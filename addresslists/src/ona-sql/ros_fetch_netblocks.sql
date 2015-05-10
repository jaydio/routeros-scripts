-- Generates a list of all subnets incl. CIDR prefix
--
-- LONG_DESC: 
-- This query will return a list of all subnets together with
-- their names. The output can be used to create a set of address
-- or access control lists to be imported onto network devices
-- such as a set of routers or firewalls.
--
-- USAGE:
-- No options available for this query, just run it
--
-- Your SQL statement would go below this line:

select concat("BLOCK","-",name),
   	concat(INET_NTOA(ip_addr_start),'-',INET_NTOA(ip_addr_end)) block
from blocks
order by blocks.name
