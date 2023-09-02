#!/bin/sh
# Script to start/stop a NAT access point
#
# Symbols for needed programs

IPTABLES=iptables
IFCONFIG=/sbin/ifconfig
DHCPD=/usr/sbin/udhcpd
NAMED=/etc/init.d/bind9

# Symbols for internal and external interfaces

NET_INT=eth1
NET_EXT=ppp0

# IP address for the AP

INT_ADDR=192.168.1.1

case "$1" in
start)
	echo ""
        echo "   → Starting AP mode for $NET_INT at address $INT_ADDR"
	echo ""
	echo ""

        echo "   → Disable packer forwarding"
        echo ""
        echo 0 > /proc/sys/net/ipv4/ip_forward

	# Disable ipv6-packet forwarding
	# echo 0 > /proc/sys/net/ipv6/conf/wlan0/forwarding
        # Stop any existing hostapd and dhcpd daemons

	echo ""
	echo "   → Killing udhcpd if it already exist"
        echo ""

        # killproc udhcpd

	echo ""
        echo "   → Set up forwarding"
        echo ""
        $IPTABLES -t nat -A POSTROUTING -o $NET_EXT -j MASQUERADE
        $IPTABLES -A FORWARD -i $NET_EXT -o $NET_INT -m state --state RELATED,ESTABLISHED -j ACCEPT
        $IPTABLES -A FORWARD -i $NET_INT -o $NET_EXT -j ACCEPT

	echo ""
        echo "   → Enable packet forwarding"
        echo ""
        echo 1 > /proc/sys/net/ipv4/ip_forward

	# Enable ipv6-packet forwarding
        # echo 1 > /proc/sys/net/ipv6/conf/wlan0/forwarding
        # Get the internal interface in the right state

	echo ""
        echo "   → Configuring wireless interface"
        echo ""
        $IFCONFIG $NET_INT down
        $IFCONFIG $NET_INT up
        $IFCONFIG $NET_INT $INT_ADDR

	echo ""
        echo "   → UDHCPD needs to have a leases file available - create it if needed"
        echo ""
        if [ ! -f /var/lib/misc/udhcpd.leases ]; then
                touch /var/lib/misc/udhcpd.leases
        fi

	echo ""
        echo "   → Bring up the UDHCP server"
        echo ""
        $DHCPD /etc/udhcpd.lan.conf $NET_INT

	echo ""
        echo "   → Bring up the bind9 server"
        echo ""
        $NAMED restart

        ;;
stop)
        # killproc udhcpd
	$NAMED stop
	$IPTABLES -F

        ;;
*)
        echo "Usage: $0 {start|stop}"
        exit 1

        ;;
esac
