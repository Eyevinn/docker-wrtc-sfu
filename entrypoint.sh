#!/bin/bash

: "${HTTP_PORT:=8080}"
: "${LOG_LEVEL:=INFO}"
: "${LOG_STD_OUT:=true}"
: "${UDP_PORT:=0}"
: "${UDP_PORT_LOW:=10006}"
: "${UDP_PORT_HI:=11000}"
: "${TCP_ENABLE:=false}"

cat > config.json << EOF
{
  "logStdOut": ${LOG_STD_OUT},
  "port": 8181,
  "logLevel": "${LOG_LEVEL}",
  "ice.singlePort": ${UDP_PORT},
  "ice.udpPortRangeLow": ${UDP_PORT_LOW},
  "ice.udpPortRangeHigh": ${UDP_PORT_HI},
  "ice.tcp.enable": ${TCP_ENABLE},
  "ice.publicIpv4": "${IPV4_ADDR}",
  "ice.publicIpv6": "${IPV6_ADDR}",
  "defaultLastN": 1,
  "rctl.enable": true,
  "rctl.debugLog": false,
  "mixerInactivityTimeoutMs": 30000,
  "recording.singlePort": 0
}
EOF

cat > nginx.conf << EOF
events {}
http {
  server {
    listen  0.0.0.0:${HTTP_PORT};
    location / {
      proxy_set_header Host \$host;
      proxy_pass http://127.0.0.1:8181;
    }
    location = / {
      access_log off;
      proxy_pass http://127.0.0.1:8181/about/health;
    }
  }
}
EOF

/usr/sbin/nginx -c /app/nginx.conf -g "daemon on;"
./smb config.json
