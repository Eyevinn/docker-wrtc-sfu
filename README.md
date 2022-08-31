# docker-wrtc-sfu

Docker container of [Symphony Media Bridge](https://github.com/finos/SymphonyMediaBridge)
that can be used as SFU in a WebRTC based broadcast streaming solution.

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
      - UDP_PORT=0
    logging:
      driver: "local"
      options:
        max-size: 10m
```

## Configuration

Default configuraiton can be changed by setting these environment variables:
- `HTTP_PORT`
- `UDP_PORT` : 0 to use port range
- `UDP_PORT_LOW`
- `UDP_PORT_HIGH`
- `LOG_LEVEL`
- `LOG_STD_OUT`
- `TCP_ENABLE`
- `IPV4_ADDR` (no quotes)
