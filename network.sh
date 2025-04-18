#!/bin/sh


    . ./variables.env

ip link set wlan0 down
brctl addbr br-wan
brctl addif br-wan $network_interface
ip link set br-wan up
dhclient br-wan
ip route del default via 192.168.1.1 dev $network_interface

