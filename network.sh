#!/bin/sh

ip link set wlan0 down
brctl addbr br-wan
brctl addif br-wan eth0
ip link set br-wan up
dhclient br-wan
ip route del default via 192.168.1.1 dev eth0

