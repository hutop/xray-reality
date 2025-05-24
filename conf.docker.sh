#!/bin/bash

# Extract the desired variables using jq
name=$(jq -r '.name' default.json)
email=$(jq -r '.email' default.json)
port=${EXPOSE_PORT:443}
sni=$(jq -r '.sni' default.json)
path=$(jq -r '.path' default.json)

bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version v1.8.23

json=$(echo default.json)

keys=$(xray x25519)
pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$(curl -s ifconfig.me)
uuid=$(xray uuid)
shortId=$(openssl rand -hex 8)
url="vless://$uuid@$serverIp:$port?path=%2F&security=reality&encryption=none&pbk=$pub&fp=chrome&type=http&sni=yahoo.com&sid=$shortId#IRVLESS-REALITY-04"

newJson=$(echo "$json" | jq \
    --arg pk "$pk" \
    --arg uuid "$uuid" \
    --arg port "$port" \
    --arg sni "$sni" \
    --arg path "$path" \
    --arg email "$email" \
    '.inbounds[0].port= '"$(expr "$port")"' |
     .inbounds[0].settings.clients[0].email = $email |
     .inbounds[0].settings.clients[0].id = $uuid |
     .inbounds[0].streamSettings.realitySettings.dest = $sni + ":443" |
     .inbounds[0].streamSettings.realitySettings.serverNames |= . + ["'$sni'", "www.'$sni'"] |
     .inbounds[0].streamSettings.realitySettings.privateKey = $pk |
     .inbounds[0].streamSettings.realitySettings.shortIds |= . + ["'$shortId'"]')

touch /usr/local/etc/xray/config.json
echo "$newJson" | tee /usr/local/etc/xray/config.json >/dev/null

service xray restart


echo "$url" >> /root/test.url

exit 0