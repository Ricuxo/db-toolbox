-- proc_sys_net

echo '100 5000 640 2560 150 30000 5000 1884 2'>/proc/sys/vm/bdflush
hdparm -m16 -c1 -d1 -a8 /dev/hda
hdparm -m16 -c1 -d1 -a8 /dev/hdb
echo '131071'>/proc/sys/net/core/rmem_default
echo '262143'>/proc/sys/net/core/rmem_max
echo '131071'>/proc/sys/net/core/wmem_default
echo '262143'>/proc/sys/net/core/wmem_max
echo '4096 65536 4194304'>/proc/sys/net/ipv4/tcp_wmem
echo '4096 87380 4194304'>/proc/sys/net/ipv4/tcp_rmem