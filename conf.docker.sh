#!/bin/bash
json=$(curl -s https://raw.githubusercontent.com/hutop/xray-reality/refs/heads/master/config.json)

keys=$(xray x25519)
pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$(curl -s ifconfig.me)
uuid=$(xray uuid)
shortId=$(openssl rand -hex 8)
url="vless://$uuid@$serverIp:${EXPOSE_PORT:443}?path=%2F&security=reality&encryption=none&pbk=$pub&fp=chrome&type=http&sni=yahoo.com&sid=$shortId#IRVLESS-REALITY-04"

newJson=$(echo "$json" | jq \
    --arg pk "$pk" \
    --arg uuid "$uuid" \
    '.inbounds[0].streamSettings.realitySettings.privateKey = $pk | 
     .inbounds[0].settings.clients[0].id = $uuid |
     .inbounds[0].streamSettings.realitySettings.shortIds += ["'$shortId'"]')
echo "$newJson" | tee /usr/local/etc/xray/config.json >/dev/null

service xray restart


echo "$url" >> /root/test.url

exit 0