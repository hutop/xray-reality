FROM ubuntu:22.04

LABEL maintainer="hutopchan@yahoo.com"
LABEL version="0.1"
LABEL description="docker image for xray reality from https://github.com/sajjaddg/xray-reality"

ARG CUS_PORT=443

ENV EXPOSE_PORT=${CUS_PORT}

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends systemd dbus curl unzip jq openssl qrencode unzip tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# clean the default unit of systemd
RUN rm -f /lib/systemd/system/*.wants/* && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*

# Set the timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install Xray-core
RUN curl -L -H "Cache-Control: no-cache" -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v1.8.0/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray
#end 

#install xray-reality
WORKDIR /root/
COPY ./conf.docker.sh ./install.sh
COPY ./default.json ./default.json
RUN sh install.sh
RUN qrencode -s 50 -o qr.png $(cat test.url)
#end 

ENTRYPOINT ["tail", "-f", "/dev/null"]

EXPOSE ${CUS_PORT}