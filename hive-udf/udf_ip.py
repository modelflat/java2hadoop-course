import sys, bisect

from utils import *


def ip2num_str(ip):
    return ip2num(*map(int, ip.split('.'))).value


ips = ()
names = ()
name_map = ()


def find_network_for_ip(ip):
    ip_num = ip2num_str(ip)
    idx = bisect.bisect_left(ips, ip_num)
    return ips[idx - 1] if idx > 0 else 0


# Assuming that it is called against single field 'network' (ipv4/mask)
def main():

    print("LOADED. Awaiting input...")

    for line in sys.argv[1:]:
        line = line.strip()
        print(
            mask_num2str(find_network_for_ip(line))
        )
