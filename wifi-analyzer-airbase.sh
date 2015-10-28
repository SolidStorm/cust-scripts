#!/bin/bash
#Device mon0 must be monitor mode from airmon-ng and script must be run as root.
#Be sure to modify the IP address in the last 3 iptables commands. The first one should be the gateway, the last two should be your internal IP
#To modify to proxy through Mallory, just set the port to the Mallory port (20755).

# README - from here : http://foxglovesecurity.com/2015/10/26/car-hacking-for-plebs-the-untold-story/

sudo su
airmon-ng start wlan0
service network-manager stop
sleep 5
ifconfig eth0 up
dhclient eth0
airbase-ng -c 7 -e CONNECT_HERE mon0 &
sleep 5
ifconfig at0 up
ifconfig at0 192.168.2.129 netmask 255.255.255.128
route add -net 192.168.2.128 netmask 255.255.255.128 gw 192.168.2.129
dhcpd -d -f  -pf /var/run/dhcp-server/dhcpd.pid at0 &
sleep 5
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to 8.8.8.8
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.174.162:54321
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 192.168.174.162:54321
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.174.162:54321
iptables -t nat -A PREROUTING -p tcp --dport 8443 -j DNAT --to-destination 192.168.174.162:54321
