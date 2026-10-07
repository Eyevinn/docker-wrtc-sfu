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
: "${VIDEO_CODEC:=VP8}"
: "${H264_PROFILE_LEVEL_ID:=42001f}"
: "${H264_PACKETIZATION_MODE:=1}"
: "${RCTL_INITIAL_ESTIMATE:=1200}"
: "${RCTL_FLOOR:=300}"
: "${RCTL_CEILING:=9000}"

if [ -z "$IPV4_ADDR" ]; then
  IPV4_ADDR=$(wget -qO- https://ipinfo.io/ip | tr -d '\n')
fi

echo "Using IPv4 address: $IPV4_ADDR"

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
  "rctl.initialEstimate": ${RCTL_INITIAL_ESTIMATE},
  "rctl.floor": ${RCTL_FLOOR},
  "rctl.ceiling": ${RCTL_CEILING},
  "codec.videoCodec": "${VIDEO_CODEC}",
  "codec.h264ProfileLevelId": "${H264_PROFILE_LEVEL_ID}",
  "codec.h264PacketizationMode": ${H264_PACKETIZATION_MODE},
  "mixerInactivityTimeoutMs": ${INACTIVITY_TIMEOUT},
  "recording.singlePort": 0,
  "numWorkerTreads": ${WORKER_THREADS}
}
EOF

cat > nginx.conf << EOF
events {}
http {
  # Raise map_hash_bucket_size above the 64-byte default. The maps below are
  # keyed on the API_KEY value; a long API_KEY (for example keys provisioned
  # when deploying via Open Source Cloud) overflows the default bucket, so
  # nginx fails at startup with
  #   could not build map_hash, you should increase map_hash_bucket_size: 64
  # never binds the listen port, and the proxy then returns 502 on every path.
  map_hash_bucket_size 128;

  map \$http_x_apikey \$api_key_valid {
    default "";
    "${API_KEY}" "ok";
  }
  
  map \$http_authorization \$bearer_token {
    default "";
    ~^Bearer\s+(.+)$ \$1;   # captures token part
  }

  map \$bearer_token \$api_bearer_token_valid {
    default "";
    "${API_KEY}" "ok";
  }

  map \$api_key_valid\$api_bearer_token_valid \$api_access_granted {
    default 0;
    ~ok 1;
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
      if (\$api_access_granted = 0) {
        return 401; # Forbidden
      }
      return 204; # OK
    }
  }
}
EOF

/usr/sbin/nginx -c /app/nginx.conf -g "daemon on;"
smb config.json