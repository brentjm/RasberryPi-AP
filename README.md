# Setup a Wifi access point on a Raspberry Pi with Ansible

## Dependencies

* Ansible >= 2.8
* Raspberry Pi 3 or 4

## Caveats
The playbook is designed to work with systemd.

## Usage

1. Modify the configuration in `access_point/vars/main.yml` (ssid, interfaces etc...)
5. Encrypt the Wifi passphrase with `ansible-vault encrypt_string -n passphrase --output access_point/vars/secret.yml <passphrase>`
6. Run `ansible-playbook --ask-vault-pass setup.yml -e target=localhost`
7. Reboot and enjoy !
