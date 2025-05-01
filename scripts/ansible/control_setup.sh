#!/bin/bash

# find os version
cat /etc/os-release

# update packages list
sudo apt update

# show python version available
apt show python3

# install python
sudo apt install python3

# check python version
python3 --version

# install Ansible (Debian)
UBUNTU_CODENAME=jammy
wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
yes | sudo apt update && sudo apt install ansible

# confirm ansible installation
ansible --version

# check version of ansible package installed
ansible-community --version

#============
# argcomplete
# install Ansible command shell completion
sudo apt install python3-argcomplete

# argcomplete Global configuration
activate-global-python-argcomplete --user