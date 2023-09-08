#!/bin/bash

# Start a long-running process to keep the container pipes open
sleep infinity < /proc/1/fd/0 > /proc/1/fd/1 2>&1 &
# Wait a bit before retrieving the PID
sleep 1
# Save the long-running PID on file
echo $! > /container-pipes-pid

if [ -v IPS ]; then # Is a
    # set up sysctl
    echo "net.ipv4.ip_forward=1
    net.ipv4.conf.all.forwarding=1
    net.ipv4.conf.all.proxy_arp=1
    net.ipv4.conf.default.rp_filter=0
    net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf

    # Set up logging structure
    mkdir /var/log/quagga
    chown quagga:quagga /var/log/quagga/
    touch /var/log/quagga/zebra.log
    chown quagga:quagga /var/log/quagga/zebra.log
    touch /var/log/quagga/ospfd.log
    chown quagga:quagga /var/log/quagga/ospfd.log

    # Setup zebra.conf
    touch /etc/quagga/zebra.conf
    echo "hostname Router
    password zebra
    enable password zebra
    log file /var/log/quagga/zebra.log" >> /etc/quaggazebra.conf

    # Setup ospfd.conf  
    touch /etc/quagga/ospfd.conf
    echo "log file /var/log/quagga/ospfd.log
    router ospf" >> /etc/quagga/ospfd.conf
    for ip in ${IPS//:/ };
    do
        echo "network $ip/24 area 0.0.0.0" >> /etc/quagga/ospfd.conf
    done

    # Correct permissions for conf files
    chown quagga:quagga /etc/quagga/*.conf
    chmod 640 /etc/quagga/*.conf
else # Is a host
    route add -net $TARGET gw $GW
fi


# Start systemd as PID 1
exec /lib/systemd/systemd