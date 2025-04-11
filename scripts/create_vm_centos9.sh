#!/bin/bash

readonly LOG_FILE_NAME="create_vm_centos9.sh.log"
HOME_DIR = $1

# list supported OS types
VBoxManage list ostypes
#--- Note:
#ID:          Fedora_64
#Description: Fedora (64-bit)
#Family ID:   Linux
#Family Desc: Linux
#64 bit:      true

# create VM
VBoxManage createvm --name Centos9Test --ostype Fedora_64 --register

# show VM details
VBoxManage showvminfo Centos9Test

# configure hardware settings
VBoxManage modifyvm Centos9Test --cpus 2 --memory 2048 --vram 12
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

# download Centos 9 iso
wget https://mirrors.centos.org/mirrorlist?path=/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso
# or copy file

# connect VM drive to host drive
VBoxManage storageattach Centos9Test --storagectl "IDE Controller" --port 0  --device 0 --type dvddrive --medium "$HOME_DIR/CentOS-Stream-9-latest-x86_64-dvd1.iso"
VBoxManage showvminfo Centos9Test | grep "IDE Controller"

# check virtualbox version (7.0.24)
vboxmanage --version
# download (pick same extension pack version as virtualbox version)
wget https://download.virtualbox.org/virtualbox/7.0.24/Oracle_VM_VirtualBox_Extension_Pack-7.0.24.vbox-extpack
# install extension pack
yes | sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-7.0.24.vbox-extpack
# verify
VBoxManage list extpacks

# enable VRDE server (VirtualBox Remote Desktop Extension)
VBoxManage modifyvm Centos9Test --vrde on
VBoxManage showvminfo Centos9Test | grep VRDE

# check processor information (intel)
lscpu
# disable KVM kernel extension
sudo modprobe -r kvm-intel

# enable crb
sudo dnf config-manager --set-enabled crb
# install epel-release and epel-next-release (for Centos Stream 9)
yes | sudo dnf install https://dl.fedoraproject.org/pub/epel/epel{,-next}-release-latest-9.noarch.rpm
# install xrdp server from EPEL
sudo dnf --enablerepo=epel -y install xrdp
# enable xrdp
sudo systemctl enable xrdp --now

# WIP ------------------------------------------------------------------------

# allow RDP port

# start VM for remote access
VBoxManage startvm Centos9Test --type headless
