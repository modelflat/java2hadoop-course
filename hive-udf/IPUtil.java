import org.apache.hadoop.hive.ql.exec.UDF;
import java.util.Arrays;
import java.util.List;

public class IPUtil extends UDF {

    public static long ip2num(String ip) {
        String[] repr = ip.split("\\.");
        return    (Long.parseLong(repr[0]) << 24)
                | (Long.parseLong(repr[1]) << 16)
                | (Long.parseLong(repr[2]) << 8)
                | Long.parseLong(repr[3]);
    }

    public static List<Long> net2num(String network) {
        int maskSep = network.indexOf('/');
        int maskDeg = Integer.parseInt(network.substring(maskSep + 1));
        long mask = 0xFFFFFFFF << (32 - maskDeg);
        String netBase = network.substring(0, maskSep);
        return Arrays.asList(ip2num(netBase), mask);
    }

    public static boolean belongs(String network, String ip) {
        int maskSep = network.indexOf('/');
        int maskDeg = Integer.parseInt(network.substring(maskSep + 1));
        long mask = 0xFFFFFFFF << (32 - maskDeg);
        String netBase = network.substring(0, maskSep);
        return ip2num(netBase) == (ip2num(ip) & mask);
    }

    public boolean evaluate(String network, String ip) {
        if (network == null || ip == null) {
            return false;
        }
        return belongs(network, ip);
    }
}
