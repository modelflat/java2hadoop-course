select * from purchases join geodata
    on reflect('IPUtil', 'ip2num', ip, 1) = reflect('IPUtil', 'net2num', network)
    or reflect('IPUtil', 'ip2num', ip, 2) = reflect('IPUtil', 'net2num', network)
    ...
limit 10;

create temporary function ip_belongs_to_network as 'IPUtil';
select * from purchases join geodata on ip_belongs_to_network(network, ip) limit 10;
