FROM ubuntu:18.04

RUN apt update -y && apt install iputils-ping iproute2 net-tools tcpdump quagga vim systemd -y

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]