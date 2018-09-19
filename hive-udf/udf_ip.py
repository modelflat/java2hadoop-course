import sys, bisect
from utils import *

# Will be loaded later
ips = ()
names = ()
name_map = ()


def ip2num_str(ip):
    return ip2num(*map(int, ip.split('.'))).value


def find_network_for_ip(ip):
    ip_num = ip2num_str(ip)
    idx = bisect.bisect_left(ips, ip_num)
    return idx - 1 if idx > 0 else 0


# Assuming that it is called against single field 'network' (ipv4/mask)
def main():
    for line in sys.stdin:
        line = line.strip()
        print("%s\t%s" % (line, name_map[names[find_network_for_ip(line)]]))
