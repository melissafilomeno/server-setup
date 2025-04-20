# ============== VM ================

# list existing VMs
VBoxManage list vms

# list running VMs
VBoxManage list runningvms

# list details of runing VMs
VBoxManage list -l runningvms

# get IP
# Update arp table
for i in {1..254}; do ping -c 1 192.168.2.$i & done
# find
arp -a | grep <mac>
VBoxManage guestproperty get "CentOS9Test" /VirtualBox/GuestInfo/Net/0/V4/IP
VBoxManage guestproperty get "CentOS9Test" "/VirtualBox/GuestInfo/Net/*"

VBoxManage guestproperty enumerate CentOS9Test

# VirtualBox Logs (Linux)
cd "/root/VirtualBox VMs/CentOS9Test/Logs"
# VirtualBox Logs (Win)
C:\Users\<user>\VirtualBox VMs\CentOS9\Logs

# check if openssh-server is installed
command -v sshd