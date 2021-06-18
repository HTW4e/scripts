#!/bin/bash

export PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin

# variables
ip_rules="/etc/iptables/rules.v4"
ipv6_rules="/etc/iptables/rules.v6"
cloudflare_v4="https://www.cloudflare.com/ips-v4"
cloudflare_v6="https://www.cloudflare.com/ips-v6"

# default ipv4 rules
# flush all iptable rules
iptables -F
ip6tables -F

iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# default ipv6 rules
ip6tables -P INPUT DROP
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

# allow traffic on lo interface
iptables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# allow only cloudeflare ips on https
for ip in $(curl $cloudflare_v4)
do
  iptables -A INPUT -p tcp --dport 443 -s $ip -j ACCEPT
done

for ipv6 in $(curl $cloudflare_v6)
do
  ip6tables -A INPUT -p tcp --dport 443 -s $ipv6 -j ACCEPT
done

# drop all non cloudflare traffic on port 80/443
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP
ip6tables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP

# allow ssh
iptables -A INPUT -p tcp --dport ssh -m state --state NEW,ESTABLISHED -j ACCEPT

# save iptables rules
iptables-save > $ip_rules
ip6tables-save > $ipv6_rules
