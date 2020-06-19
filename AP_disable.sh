#!/bin/bash
############################################################
# Script for disabling access point on Linux like the Raspberry Pi 3.
# From the following links:
# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md
# https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point/
# https://fwhibbit.es/en/automatic-access-point-with-docker-and-raspberry-pi-zero-w

# Created: Brent Maranzano
# Last modified: June 17, 2020

# Example to run (as root):
# root>./AP_disable.sh
############################################################

# Install hostapd and dnsmasq.
DEBIAN_FRONTEND=noninteractive apt remove -y hostapd dnsmasq

# Start the hostapd service on boot.
systemctl mask hostapd
systemctl disable hostapd

# Remove the dhcp configuration in the system file.
sed -i -e '/^interface wlan0/d' /etc/dhcpcd.conf
sed -i -e '^    static ip_address=192.168.4.1/24/d' /etc/dhcpcd.conf
sed -i -e '^    nohook wpa_supplicant/d' /etc/dhcpcd.conf
sed -i -e '^    denyinterfaces wlan0/d' /etc/dhcpcd.conf

# Comment the port forwarding rule.
sed -i -e "s/net.ipv4.ip_forward=1/#net.ipv4.ip_forward=1/" /etc/sysctl.conf

# Disable port forwarding and save.
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.ipv4.nat

# Copy back the old DNS configuration.
mv /etc/dnsmasq.conf.orig /etc/dnsmasq.conf

# Remove the hostapd configuration file.
rm /etc/hostapd/hostapd.conf

# Reboot the system.
systemctl reboot
