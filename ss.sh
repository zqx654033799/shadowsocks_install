#!/bin/bash
cd `dirname $0`

function save_iptables()
{
    port_list=$(python ss.py port)
    ports=(${port_list//\n/ })
    iptables='*filter\n:INPUT ACCEPT [0:0]\n:FORWARD ACCEPT [0:0]\n:OUTPUT ACCEPT [1:140]\n-A INPUT -p udp -m state --state NEW -m udp --dport 80 -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT\n-A INPUT -p udp -m state --state NEW -m udp --dport 443 -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT\n'
    for port in ${ports[@]}
    do
    iptables=${iptables}"-A INPUT -p tcp -m state --state NEW -m tcp --dport $port -j ACCEPT\n"
    iptables=${iptables}"-A INPUT -p udp -m state --state NEW -m udp --dport $port -j ACCEPT\n"
    done
    iptables=${iptables}"-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT\n-A INPUT -p icmp -j ACCEPT\n-A INPUT -i lo -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT\n-A INPUT -j REJECT --reject-with icmp-host-prohibited\n-A FORWARD -j REJECT --reject-with icmp-host-prohibited\nCOMMIT\n"
    echo -e "$iptables" &> /etc/sysconfig/iptables
}

if [ "$1"x = "add"x ]; then
    python ss.py $1 $2 $3
    if [ $? -eq 0 ]; then
        service shadowsocks restart
        save_iptables
        /etc/init.d/iptables restart
    fi
elif [ "$1"x = "remove"x ]; then
    python ss.py $1 $2
    if [ $? -eq 0 ]; then
        service shadowsocks restart
        save_iptables
        /etc/init.d/iptables restart
    fi
elif [ "$1"x = "list"x ]; then
    python ss.py $1
else
    echo -e 'usage: \n\tadd\tport[1-65535]\tpassword\n\tremove\tport[1-65535]\n\tlist'
fi
