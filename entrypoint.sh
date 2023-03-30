#!/bin/sh

set -eu

TROJAN_CERT_DIR=/root/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory

echo "生成Caddyfile..."
cat > /etc/caddy/Caddyfile <<-EOF
http://${DOMAIN}:80 {
    root * /opt/trojan/wwwroot
    log {
        output file /var/log/caddy.log
    }
    file_server
}
https://${DOMAIN}:8443 {
    root * /opt/trojan/wwwroot
    log {
        output file /var/log/caddy.log
    }
    file_server
}
EOF

echo "启动caddy..."
caddy start --config /etc/caddy/Caddyfile --adapter caddyfile

while [ ! -f ${TROJAN_CERT_DIR}/${DOMAIN}/${DOMAIN}.crt ]; do
  echo "等待证书生成..."
  sleep 5
done

echo "生成trojan配置..."
cat > /etc/trojan-go/config.json <<-EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "${DOMAIN}",
    "remote_port": 80,
    "password": [
        "${PASSWORD:-123456}"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "${TROJAN_CERT_DIR}/${DOMAIN}/${DOMAIN}.crt",
        "key": "${TROJAN_CERT_DIR}/${DOMAIN}/${DOMAIN}.key",
        "key_password": "",
        "cipher_tls13":"TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "router":{
        "enabled": true,
        "block": [
            "geoip:private"
        ]
    }
}
EOF

echo "trojan链接：trojan://${PASSWORD}@${DOMAIN}:443#${DOMAIN}"

echo "启动trojan-go..."
/usr/bin/trojan-go -config /etc/trojan-go/config.json
