#!/bin/sh

ddns=$(uci get openvpn.myvpn.ddns 2>/dev/null)
port=$(uci get openvpn.myvpn.port 2>/dev/null)
proto=$(uci get openvpn.myvpn.proto 2>/dev/null)

ddns=$(echo "$ddns" | tr -cd "a-zA-Z0-9._-")
port=$(echo "$port" | tr -cd "0-9")
proto=$(echo "$proto" | tr -cd "a-z")

[ -z "$proto" ] && proto="udp"

cat > /tmp/my.ovpn  <<EOF
client
dev tun
proto $proto
remote $ddns $port
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
EOF
echo "<ca>" >> /tmp/my.ovpn
cat /etc/openvpn/pki/ca.crt >> /tmp/my.ovpn
echo "</ca>" >> /tmp/my.ovpn
echo "<cert>" >> /tmp/my.ovpn
cat /etc/openvpn/pki/client1.crt >> /tmp/my.ovpn
echo "</cert>" >> /tmp/my.ovpn
echo "<key>" >> /tmp/my.ovpn
cat /etc/openvpn/pki/client1.key >> /tmp/my.ovpn
echo "</key>" >> /tmp/my.ovpn
[ -f /etc/ovpnadd.conf ] && cat /etc/ovpnadd.conf >> /tmp/my.ovpn
