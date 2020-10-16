#!/bin/bash
############################################################
# Script for setting up access point on Linux like the Raspberry Pi 3.
# From the following links:
# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md
# https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point/
# https://fwhibbit.es/en/automatic-access-point-with-docker-and-raspberry-pi-zero-w

# Created: Brent Maranzano
# Last modified: June 17, 2020

# Example to run (as root):
# root>./AP_setup.sh
############################################################
read -p 'Input the 3rd octet of the network IP address (IP -> 192.168.$IP.xxx/24): ' IP
read -p 'Input the SSID: ' SSID
read -p 'Input the channel: ' CHANNEL
read -p 'Input the password: ' PASSWORD

echo "/n Install packages hostapd dnsmasq netfilter-persistent iptables-persistent"
DEBIAN_FRONTEND=noninteractive apt install -y hostapd dnsmasq netfilter-persistent iptables-persistent

echo "/nAppend the wireless configuration into a temporary dhcpcd.conf file"
cat /etc/dhcpcd.conf > dhcpcd.conf
sed -i -e '$ainterface wlan0' dhcpcd.conf
sed -i -e '$a\ \ \ \ \ static ip_address=192.168.'"$IP"'.1/24' dhcpcd.conf
sed -i -e '$a\ \ \ \ \ nohook wpa_supplicant' dhcpcd.conf
#sed -i -e '$a\ \ \ \ \ denyinterfaces wlan0' dhcpcd.conf

echo "Create the dnsmasq.conf file from the template."
sed -e 's/Number/'"$IP"'/g' dnsmasq.conf_template > dnsmasq.conf

echo "Create the hostapd.conf file from the template."
sed -e 's/NameOfNetwork/'"$SSID"'/' hostapd.conf_template > hostapd.conf
sed -i -e 's/ChannelNumber/'"$CHANNEL"'/' hostapd.conf
sed -i -e 's/WiFiPassword/'"$PASSWORD"'/' hostapd.conf

echo "Backup the old dhcpcd.conf file and copy over the new configuration file."
mv /etc/dhcpcd.conf /etc/dhcpcd.conf.orig
mv dhcpcd.conf /etc/dhcpcd.conf

echo "Backup the old dnsmasq.conf file and copy over the new configuration file."
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
mv dnsmasq.conf /etc/dnsmasq.conf

echo "Backup the old hostapd.conf file and copy over the new configuration file."
mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.orig
mv hostapd.conf /etc/hostapd/hostapd.conf

echo "Start the hostapd service on boot."
systemctl unmask hostapd
systemctl enable hostapd

echo "Uncomment the port forwarding rule."
sed -i -e "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf

echo "Enable port forwarding and save."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
netfilter-persistent save
#iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#iptables-save > /etc/iptables.ipv4.nat
#sed -e '/exit 0/iiptables-restore < /etc/iptables.ipv4.nat/' /etc/rc.local

echo "Unblock any radio signals."
rfkill unblock wlan

echo "Reboot the system."
systemctl reboot
