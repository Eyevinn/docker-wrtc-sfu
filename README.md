# docker-wrtc-sfu

Docker container of [Symphony Media Bridge](https://github.com/finos/SymphonyMediaBridge)
that can be used as SFU in a WebRTC based broadcast streaming solution.

## Deploy on Open Source Cloud

Deploy this SFU with one click on [Open Source Cloud](https://www.osaas.io/).

[![Badge OSC](https://img.shields.io/badge/Evaluate-24243B?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTIiIGZpbGw9InVybCgjcGFpbnQwX2xpbmVhcl8yODIxXzMxNjcyKSIvPgo8Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSI3IiBzdHJva2U9ImJsYWNrIiBzdHJva2Utd2lkdGg9IjIiLz4KPGRlZnM%2BCjxsaW5lYXJHcmFkaWVudCBpZD0icGFpbnQwX2xpbmVhcl8yODIxXzMxNjcyIiB4MT0iMTIiIHkxPSIwIiB4Mj0iMTIiIHkyPSIyNCIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiPgo8c3RvcCBzdG9wLWNvbG9yPSIjQzE4M0ZGIi8%2BCjxzdG9wIG9mZnNldD0iMSIgc3RvcC1jb2xvcj0iIzREQzlGRiIvPgo8L2xpbmVhckdyYWRpZW50Pgo8L2RlZnM%2BCjwvc3ZnPgo%3D)](https://app.osaas.io/browse/eyevinn-docker-wrtc-sfu)

## Docker Compose

Example docker-compose file:

```
version: "3.7"

services:
  sfu:
    image: eyevinntechnology/wrtc-sfu:latest
    restart: always
    network_mode: "host"
    cap_add:
      - SYS_NICE
    ulimits:
      rtprio: 99
    environment:
      - HTTP_PORT=8180
      - UDP_PORT=10000
      - API_KEY=<api-key>
    logging:
      driver: "local"
      options:
        max-size: 10m
```

## Configuration

Default configuraiton can be changed by setting these environment variables:
- `HTTP_PORT`
- `HTTP_BIND_PORT` : when running two containers on the same host in `host` network mode you can override the default port that the SMB service binds the HTTP API to.
- `UDP_PORT`
- `NUM_UDP_PORTS`
- `LOG_LEVEL`
- `LOG_STD_OUT`
- `TCP_ENABLE`
- `IPV4_ADDR` (no quotes)
- `API_KEY` : Override default api-key to access endpoint (eyevinn).
