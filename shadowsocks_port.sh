#!/bin/sh

port=8381
sleep_time=30
max_bandwidth=1024000000000
basepath=`dirname $0`

sleep 10

file_bandwidth=0
for i in `cat $basepath/shadowsocks_$port.db`;
do
let "file_bandwidth+=i"
done
echo "file count bandwidth :$file_bandwidth"

if [ "$file_bandwidth" -gt "$max_bandwidth" ]; then
echo "exit"
exit
else
udp_dpt_string=`iptables -vxn -L | grep -i "udp dpt:$port"`
tcp_dpt_string=`iptables -vxn -L | grep -i "tcp dpt:$port"`
if [ ! -n "$udp_dpt_string" -o ! -n "$tcp_dpt_string" ]; then
`iptables -I INPUT -p udp --dport $port -j ACCEPT`
`iptables -I INPUT -p tcp --dport $port -j ACCEPT`
`iptables -I OUTPUT -p udp --sport $port`
`iptables -I OUTPUT -p tcp --sport $port`
fi
fi

while true
do
count_bandwidth=$file_bandwidth
udp_dpt_bandwidth=`iptables -vxn -L | grep -i "udp dpt:$port" | awk '{print $2}'`
udp_spt_bandwidth=`iptables -vxn -L | grep -i "udp spt:$port" | awk '{print $2}'`
tcp_dpt_bandwidth=`iptables -vxn -L | grep -i "tcp dpt:$port" | awk '{print $2}'`
tcp_spt_bandwidth=`iptables -vxn -L | grep -i "tcp spt:$port" | awk '{print $2}'`
echo "udp_dpt_bandwidth :$udp_dpt_bandwidth"
echo "udp_spt_bandwidth :$udp_spt_bandwidth"
echo "tcp_dpt_bandwidth :$tcp_dpt_bandwidth"
echo "tcp_spt_bandwidth :$tcp_spt_bandwidth"
let "count_bandwidth+=udp_dpt_bandwidth"
let "count_bandwidth+=udp_spt_bandwidth"
let "count_bandwidth+=tcp_dpt_bandwidth"
let "count_bandwidth+=tcp_spt_bandwidth"
echo "count bandwidth :$count_bandwidth"

`echo "$count_bandwidth" > $basepath/shadowsocks_$port.db`
echo "write file $basepath/shadowsocks_$port.db"

if [ "$count_bandwidth" -gt "$max_bandwidth" ]; then
`iptables -D INPUT -p udp --dport $port -j ACCEPT`
`iptables -D INPUT -p tcp --dport $port -j ACCEPT`
`iptables -D OUTPUT -p udp --sport $port`
`iptables -D OUTPUT -p tcp --sport $port`
echo "port delete: $port"
exit
fi
sleep $sleep_time
done
