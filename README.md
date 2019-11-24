# Setup a Wifi access point on a Raspberry Pi with Ansible

## Dependencies

* Ansible >= 2.8
* Raspberry Pi 3 or 4

## Usage

1. Install Raspbian (follow the steps in the next section)
2. Install Ansible

```bash
# Add the following line to /etc/apt/sources.list
# deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main 
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt update
sudo apt install ansible
```

3. Clone this repository `git clone https://github.com/icecr4ck/rpi_access_point`
4. Modify the configuration in `access_point/vars/main.yml` (ssid, passphrase, interfaces etc...)
5. The passphrase can be encrypted with `ansible-vault encrypt_string <passphrase>`
6. Run `ansible-playbook --ask-vault-pass setup.yml -e target=local`
7. Reboot and enjoy !

## Install Raspbian on a Raspberry Pi

1. Download the ISO image at https://www.raspberrypi.org/downloads/raspbian
2. Unzip the archive and plug the micro-sd card on the host
3. Run `sudo dd bs=1m if=raspbian.iso of=/dev/sdX conv=sync`
4. Go to the root of the volume and run `touch ssh` to enable SSH
5. Get the IP of the Raspberry with a `nmap -sL <network_ip>/<mask>` (default hostname is raspberrypi)
6. Login with pi:raspberry
7. Run `sudo raspi-config` to setup the Raspberry (hostname, Wifi, passwd, free space, region settings)
8. Run `sudo rpi-update` to upgrade the firmware
9. Change the default username 

```bash
usermod -l <username> pi
usermod -m -d /home/<username> <username>
```

10. Update and upgrade the system with `apt update && apt dist-upgrade`
