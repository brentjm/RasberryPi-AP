#!/bin/bash
############################################################
# Script for setting up access point on Linux like the Raspberry Pi 3.
# From the following links:
# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md
# https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point/
# https://fwhibbit.es/en/automatic-access-point-with-docker-and-raspberry-pi-zero-w

# Created: Brent Maranzano
# Last modified: June 17, 2020

# Configuation modfifications:
# 1. dnsmasq.conf to change the network settings
#   a. served IP range (dhcpcd.conf also)
#   b. domain name
# 2. hostapd.conf to change WiFi settings
#   a. SSID
#   b. WiFi password
#   c. radio band
#   d. encryption settings
# 3. dhcpcd.conf
#   a. IP range (dnsmasq.conf also)


# Example to run (as root):
# root>./AP_setup.sh
############################################################

# Install hostapd and dnsmasq.
DEBIAN_FRONTEND=noninteractive apt install -y hostapd dnsmasq

# Start the hostapd service on boot.
systemctl unmask hostapd
systemctl enable hostapd

# Append the dhcp configuration into the system file.
# Changed from cat to sed, easier to confirm the reverse
#cat dhcpcd.conf >> /etc/dhcpcd.conf
sed -i -e '$ainterface wlan0' /etc/dhcpcd.conf
sed -i -e '$a    static ip_address=192.168.4.1/24' /etc/dhcpcd.conf
sed -i -e '$a    nohook wpa_supplicant' /etc/dhcpcd.conf
sed -i -e '$a    denyinterfaces wlan0' /etc/dhcpcd.conf

# Uncomment the port forwarding rule.
sed -i -e "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf

# Enable port forwarding and save.
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.ipv4.nat
sed -e '/exit 0/iiptables-restore < /etc/iptables.ipv4.nat/' /etc/rc.local

# Backup the old DNS configuration and copy over the new configuration.
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cp dnsmasq.conf /etc/dnsmasq.conf

# Unblock any radio signals.
rfkill unblock wlan

# Copy over the hostapd configuration file.
cp hostapd.conf /etc/hostapd/hostapd.conf

# Reboot the system.
systemctl reboot
