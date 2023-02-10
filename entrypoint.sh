#!/bin/bash

: "${HTTP_PORT:=8080}"
: "${LOG_LEVEL:=INFO}"
: "${LOG_STD_OUT:=true}"
: "${UDP_PORT:=10000}"
: "${NUM_UDP_PORTS:=1}"
: "${TCP_ENABLE:=false}"
: "${API_KEY:=eyevinn}"
: "${HTTP_BIND_PORT:=8181}"
: "${WORKER_THREADS:=0}"
: "${INACTIVITY_TIMEOUT:=60000}"

cat > config.json << EOF
{
  "logStdOut": ${LOG_STD_OUT},
  "port": ${HTTP_BIND_PORT},
  "logLevel": "${LOG_LEVEL}",
  "ice.singlePort": ${UDP_PORT},
  "ice.sharedPorts": ${NUM_UDP_PORTS},
  "ice.tcp.enable": ${TCP_ENABLE},
  "ice.publicIpv4": "${IPV4_ADDR}",
  "ice.publicIpv6": "${IPV6_ADDR}",
  "rctl.enable": true,
  "rctl.debugLog": false,
  "mixerInactivityTimeoutMs": ${INACTIVITY_TIMEOUT},
  "recording.singlePort": 0,
  "numWorkerTreads": ${WORKER_THREADS}
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
      proxy_pass http://127.0.0.1:${HTTP_BIND_PORT};
      if (\$request_method = 'OPTIONS') {
        add_header Access-Control-Allow-Headers "X-APIkey, Authorization";
      }
      satisfy any;
      auth_request /authorize_apikey;
    }
    location = / {
      access_log off;
      proxy_pass http://127.0.0.1:${HTTP_BIND_PORT}/about/health;
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
