import base64, bz2, io, struct, ctypes, re


IP = re.compile("[./]")

try:
    range = xrange
except:
    pass


def ip2num(a, b, c, d):
    return ctypes.c_uint32((a << 24) | (b << 16) | (c << 8) | d)


def mask_str2num(s):
    a, b, c, d, m = map(int, re.split(IP, s))
    return ip2num(a, b, c, d)


def mask_num2str(num):
    return "{}.{}.{}.{}".format(
        (num >> 24), (num >> 16) & 0xFF, (num >> 8) & 0xFF, (num) & 0xFF
    )


def iter2base(arr, b_conv):
    b_ips = bz2.compress(b"".join(map(b_conv, arr)))
    b_in, b_out = io.BytesIO(b_ips), io.BytesIO()
    base64.encode(b_in, b_out)
    return b_out.getvalue()


def iter_unpack(fmt, bstr):
    assert len(bstr) % struct.calcsize(fmt) == 0
    chsize = struct.calcsize(fmt)
    for i in range(0, len(bstr), chsize):
        yield struct.unpack(fmt, bstr[i:i+chsize])


def base2iter(bstr):
    b_in, b_out = io.BytesIO(bstr), io.BytesIO()
    base64.decode(b_in, b_out)
    arr_repr = bz2.decompress(b_out.getvalue())
    return tuple((x[0] for x in iter_unpack("I", arr_repr)))


