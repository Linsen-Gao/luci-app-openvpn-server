#!/bin/sh

rand_str() {
    (base64 /dev/urandom | tr -dc "A-Za-z" | head -c "$1") 2>/dev/null
}

rand_str_upper() {
    (rand_str "$1" | tr "a-z" "A-Z") 2>/dev/null
}

rand_str_lower() {
    (rand_str "$1" | tr "A-Z" "a-z") 2>/dev/null
}

rand_easy_rsa_vars() {
    local KEY_PROVINCE="$(rand_str_upper 6)"
    local KEY_CITY="$(rand_str 8)"
    local KEY_ORG="$(rand_str 8)"
    local KEY_EMAIL="$(rand_str_lower 8)@$(rand_str_lower 4).$(rand_str_lower 3)"
    local KEY_OU="$(rand_str 8)"
    sed -i \
        -e "s/^[[:space:]]*set_var[[:space:]]\+EASYRSA_REQ_COUNTRY[[:space:]]\+\".*\"$/set_var EASYRSA_REQ_COUNTRY	\"$KEY_PROVINCE\"/" \
        -e "s/^[[:space:]]*set_var[[:space:]]\+EASYRSA_REQ_PROVINCE[[:space:]]\+\".*\"$/set_var EASYRSA_REQ_PROVINCE	\"$KEY_CITY\"/" \
        -e "s/^[[:space:]]*set_var[[:space:]]\+EASYRSA_REQ_CITY[[:space:]]\+\".*\"$/set_var EASYRSA_REQ_CITY	\"$KEY_ORG\"/" \
        -e "s/^[[:space:]]*set_var[[:space:]]\+EASYRSA_REQ_ORG[[:space:]]\+\".*\"$/set_var EASYRSA_REQ_ORG	\"$KEY_ORG\"/" \
        -e "s/^[[:space:]]*set_var[[:space:]]\+EASYRSA_REQ_EMAIL[[:space:]]\+\".*\"$/set_var EASYRSA_REQ_EMAIL	\"$KEY_EMAIL\"/" \
        -e "s/^[[:space:]]*set_var[[:space:]]\+EASYRSA_REQ_OU[[:space:]]\+\".*\"$/set_var EASYRSA_REQ_OU	\"$KEY_OU\"/" \
        /etc/easy-rsa/vars
}

rand_easy_rsa_vars

rm -rf /root/pki

export EASYRSA_PKI="/etc/easy-rsa/pki"
export EASYRSA_VARS_FILE="/etc/easy-rsa/vars"
export EASYRSA_CLI="easyrsa --batch"

echo -en "yes
yes
" | $EASYRSA_CLI init-pki
$EASYRSA_CLI gen-dh
$EASYRSA_CLI build-ca nopass
$EASYRSA_CLI build-server-full server nopass
$EASYRSA_CLI build-client-full client1 nopass

mkdir -p /etc/openvpn/pki
cp /etc/easy-rsa/pki/ca.crt /etc/openvpn/pki/
cp /etc/easy-rsa/pki/dh.pem /etc/openvpn/pki/
cp /etc/easy-rsa/pki/issued/server.crt /etc/openvpn/pki/
cp /etc/easy-rsa/pki/private/server.key /etc/openvpn/pki/
cp /etc/easy-rsa/pki/issued/client1.crt /etc/openvpn/pki/
cp /etc/easy-rsa/pki/private/client1.key /etc/openvpn/pki/
echo "OpenVPN Cert renew successfully"
