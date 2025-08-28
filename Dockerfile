FROM ubuntu:focal

ARG SMB_DEB_PACKAGE_DOWNLOAD_URL="https://github.com/Eyevinn/SymphonyMediaBridge/releases/download/2.4.0-550/eyevinn-smb_2.4.0-550.deb"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y install libc++-dev libc++abi-dev \
    libsrtp2-1 libmicrohttpd12 libopus0 libssl1.1 \
    nginx wget

WORKDIR /app

RUN wget ${SMB_DEB_PACKAGE_DOWNLOAD_URL} -O smbpack.deb
RUN dpkg -i smbpack.deb

COPY --chmod=755 entrypoint.sh ./entrypoint.sh

RUN echo "* - rtprio 99" >> /etc/security/limits.conf

ENTRYPOINT ["./entrypoint.sh"]

