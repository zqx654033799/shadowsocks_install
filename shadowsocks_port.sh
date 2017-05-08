#!/bin/sh

port=8381
sleep_time=5
max_bandwidth=102400
basepath=`dirname $0`

file_bandwidth=0
for i in `cat $basepath/shadowsocks_$port.log`;
do
let "file_bandwidth+=i"
done
echo "file count bandwidth :$file_bandwidth"

if [ "$file_bandwidth" -gt "$max_bandwidth" ]; then
echo "exit"
exit
else
dpt_string=`sudo iptables -vxn -L | grep -i "dpt:$port"`
if [ ! -n "$dpt_string" ]; then
`sudo iptables -I INPUT -p tcp --dport $port -j ACCEPT`
`sudo iptables -I OUTPUT -p tcp --sport $port`
fi
fi

while true
do
count_bandwidth=$file_bandwidth
dpt_bandwidth=`sudo iptables -vxn -L | grep -i "dpt:$port" | awk '{print $2}'`
spt_bandwidth=`sudo iptables -vxn -L | grep -i "spt:$port" | awk '{print $2}'`
echo "dpt_bandwidth :$dpt_bandwidth"
echo "spt_bandwidth :$spt_bandwidth"
let "count_bandwidth+=dpt_bandwidth"
let "count_bandwidth+=spt_bandwidth"
echo "count bandwidth :$count_bandwidth"

`echo "$count_bandwidth" > $basepath/shadowsocks_$port.log`
echo "write file $basepath/shadowsocks_$port.log"

if [ "$count_bandwidth" -gt "$max_bandwidth" ]; then
`sudo iptables -D INPUT -p tcp --dport $port -j ACCEPT`
`sudo iptables -D OUTPUT -p tcp --sport $port`
echo "port delete: $port"
exit
fi
sleep $sleep_time
done
