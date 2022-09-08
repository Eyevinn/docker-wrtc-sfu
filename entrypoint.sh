#!/bin/bash

: "${HTTP_PORT:=8080}"
: "${LOG_LEVEL:=INFO}"
: "${LOG_STD_OUT:=true}"
: "${UDP_PORT:=0}"
: "${UDP_PORT_LOW:=10006}"
: "${UDP_PORT_HI:=11000}"
: "${TCP_ENABLE:=false}"
: "${API_KEY:=eyevinn}"

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
  "mixerInactivityTimeoutMs": 30000
}
EOF

cat > nginx.conf << EOF
events {}
http {
  map \$http_x_apikey \$api_realm {
    default "";
    "${API_KEY}" "api_granted";
  }
  server {
    listen  0.0.0.0:${HTTP_PORT};
    location / {
      proxy_set_header Host \$host;
      proxy_pass http://127.0.0.1:8181;
      if (\$request_method = 'OPTIONS') {
        add_header Access-Control-Allow-Headers "X-APIkey, Authorization";
      }
      satisfy any;
      auth_request /authorize_apikey;
    }
    location = / {
      access_log off;
      proxy_pass http://127.0.0.1:8181/about/health;
    }
    location = /authorize_apikey {
      internal;
      if (\$api_realm = "") {
        return 403; # Forbidden
      }
      if (\$http_x_apikey = "") {
        return 401; # Unauth
      }
      return 204; # OK
    }
  }
}
EOF

/usr/sbin/nginx -c /app/nginx.conf -g "daemon on;"
./smb config.json