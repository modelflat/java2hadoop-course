import pandas
import os
import numpy as np
import utils


def convert(path):
    ff = pandas.concat([
        pandas.read_csv(os.path.join(path, n))
        for n in filter(lambda x: "csv" in x and "Locations" in x, os.listdir(path))
    ])
    ff = ff[(ff.locale_code == "en") & ~ff.country_iso_code.isna()]\
        .rename(columns={"geoname_id": "id", "country_iso_code": "code", "country_name": "name"})\
        [["id", "code", "name"]]\
        .set_index("id", verify_integrity=True)
    ip4 = pandas.read_csv(os.path.join(path, "GeoLite2-Country-Blocks-IPv4.csv"))
    ip = ip4.reset_index().rename(columns={"geoname_id": "id"})[["network", "id"]].set_index("network")
    ip = ip[~ip.id.isna()]
    ip["id"] = ip.id.apply(int)
    all = ip.join(ff, on="id", how="left")[["code", "name"]]
    return all.reset_index()


template = """#!/usr/bin/env python
# -*- coding: latin-1 -*-
# !!! AUTOGENERATED SOURCE! DON'T TOUCH ANYTHING !!!

{utils}

{udf_source}

name_map={name_map}

"""


def pack_ip_data(filename):
    ips = pandas.read_csv(filename, header=None).rename(columns={0: "network", 1: "name"})
    ips = ips[~ips.name.isna()]
    name_index = dict(t[::-1] for t in enumerate(ips.name.unique()))
    ips["network"] = ips.network.apply(lambda x: utils.mask_str2num(x).value)
    ips["name"] = ips.name.apply(lambda x: name_index[x])
    ips = ips.set_index("network").sort_index().reset_index()
    o = ips.values.T
    conv = lambda x: np.uint32(x).tobytes()
    return utils.iter2base(o[0], conv), utils.iter2base(o[1], conv), name_index


def generate_ip_udf(udf_source_filename, geo_ip_filename, output_filename):
    with open("utils.py", "r") as file:
        utils_source = file.read()
    with open(udf_source_filename, "r") as file:
        udf_source = file.read().replace("from utils import *", '')

    ips, nms, nid = pack_ip_data(geo_ip_filename)

    nid = dict(x[::-1] for x in nid.items())

    rendered = template.format(
        utils=utils_source,
        udf_source=udf_source,
        name_map=nid
    )

    with open(output_filename, "wb") as file:
        file.write(bytes(rendered, encoding="latin-1"))

    with open(output_filename, "ab") as file:
        file.write(b"ips = base2iter(b'''")
        file.write(ips)
        file.write(b"''')\n")
        file.write(b"names = base2iter(b'''")
        file.write(nms)
        file.write(b"''')\n")
        file.write(b"main()\n")

    print("UDF generated. (size ~ %.3f MiB)" % (os.stat(output_filename).st_size / 2**20,))


generate_ip_udf(
    udf_source_filename="udf_ip.py",
    geo_ip_filename="../geodata.csv",
    output_filename="../hive-scripts/gen/udf_ip_to_location.py"
)
