#!/bin/bash

readonly LOG_FILE_NAME="create_vm_centos9.sh.log"
HOME_DIR = $1
HOST_IP = $2

# list supported OS types
VBoxManage list ostypes
#--- Note:
#ID:          Fedora_64
#Description: Fedora (64-bit)
#Family ID:   Linux
#Family Desc: Linux
#64 bit:      true

# import VM
VBoxManage import CentOS8.ova --dry-run

# show VM details
VBoxManage showvminfo Centos9Test

# check cpu (Thread(s) per core)
lscpu
# check ram 
free -h
# check storage
df -h .
# configure hardware settings
VBoxManage modifyvm Centos9Test --cpus 1 --memory 512 --vram 12
VBoxManage showvminfo Centos9Test | grep "Memory size"

# configure bridged networking
ifconfig
VBoxManage modifyvm Centos9Test --nic1 bridged --bridgeadapter1 enp3s0

# create a virtual hard disk image
VBoxManage createhd --filename /home/vdi/Centos9Test.vdi --size 5120

# add storage controller
VBoxManage storagectl Centos9Test --name "SATA Controller" --add sata --bootable on

# attach hard disk to controller
VBoxManage storageattach Centos9Test --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium /home/vdi/Centos9Test.vdi

# add IDE controller for CD/DVD drive
VBoxManage storagectl Centos9Test --name "IDE Controller" --add ide

# check virtualbox version (7.0.24)
vboxmanage --version
# download (pick same extension pack version as virtualbox version)
wget https://download.virtualbox.org/virtualbox/7.0.24/Oracle_VM_VirtualBox_Extension_Pack-7.0.24.vbox-extpack
# install extension pack
yes | sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-7.0.24.vbox-extpack
# verify
VBoxManage list extpacks

# enable VRDE server (VirtualBox Remote Desktop Extension)
VBoxManage modifyvm Centos9Test --vrde on --vrdemulticon on --vrdeauthtype external --vrdeaddress $HOST_IP
# enable video redirection 
VBoxManage modifyvm Centos9Test --vrdevideochannel on
# set video quality
VBoxManage modifyvm Centos9Test --vrdevideochannelquality 75
VBoxManage showvminfo Centos9Test | grep VRDE

# enable crb
sudo dnf config-manager --set-enabled crb
# install epel-release and epel-next-release (for Centos Stream 9)
yes | sudo dnf install https://dl.fedoraproject.org/pub/epel/epel{,-next}-release-latest-9.noarch.rpm
# install xrdp server from EPEL
sudo dnf --enablerepo=epel -y install xrdp
# enable xrdp
sudo systemctl enable xrdp --now

# allow RDP port
sudo firewall-cmd --zone=public --permanent --add-port=3389/tcp
# reload firewall
sudo firewall-cmd --reload

# check processor information (intel)
lscpu
# disable KVM kernel extension
sudo modprobe -r kvm-intel

# start VM for remote access
VBoxHeadless --startvm Centos9Test --vrde config
# or run in the background
VBoxManage startvm Centos9Test --type headless
