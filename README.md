# docker-wrtc-sfu

Docker container of [Symphony Media Bridge](https://github.com/finos/SymphonyMediaBridge)
that can be used as SFU in a WebRTC based broadcast streaming solution.

## Deploy on Open Source Cloud

Deploy this SFU with one click on [Open Source Cloud](https://www.osaas.io).

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
- `VIDEO_CODEC` : Video codec, `VP8` (default) or `H264`.
- `H264_PROFILE_LEVEL_ID` : H264 profile-level-id (default `42001f`). Use `42e01f` for Constrained Baseline, which WebRTC mandates and Safari expects.
- `H264_PACKETIZATION_MODE` : H264 packetization mode (default `1`).
- `RCTL_INITIAL_ESTIMATE` : Initial bandwidth estimate in kbps (default `1200`). Consumers that do not send REMB (e.g. GStreamer webrtcbin) stay at this estimate.
- `RCTL_FLOOR` : Rate control floor in kbps (default `300`).
- `RCTL_CEILING` : Rate control ceiling in kbps (default `9000`).

The config file is generated at container start, so changing any of these on a running instance requires a restart (on Open Source Cloud: recreate the instance).
