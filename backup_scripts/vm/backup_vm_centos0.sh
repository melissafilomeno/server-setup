#------------------------------------------------------------------

# list supported OS types
VBoxManage list ostypes
#--- Note:
#ID:          Fedora_64
#Description: Fedora (64-bit)
#Family ID:   Linux
#Family Desc: Linux
#64 bit:      true

# check cpu (Thread(s) per core)
lscpu
# check ram 
free -h
# check storage
df -h .

#------------------------------------------------------------------
# enable & run with remote desktop

# check virtualbox version (7.0.24)
vboxmanage --version
# download (pick same extension pack version as virtualbox version)
wget https://download.virtualbox.org/virtualbox/7.0.24/Oracle_VM_VirtualBox_Extension_Pack-7.0.24.vbox-extpack
# install extension pack
yes | sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-7.0.24.vbox-extpack
# verify
VBoxManage list extpacks

# enable VRDE server (VirtualBox Remote Desktop Extension)
VBoxManage modifyvm CentOS9Test --vrde on --vrdemulticon on --vrdeauthtype external --vrdeaddress $HOST_IP
# enable video redirection 
VBoxManage modifyvm CentOS9Test --vrdevideochannel on
# set video quality
VBoxManage modifyvm CentOS9Test --vrdevideochannelquality 75
VBoxManage showvminfo CentOS9Test | grep VRDE

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

# start with vrde
VBoxHeadless --startvm CentOS9Test --vrde config

#----------------------------------------------------
Set IP

VBoxManage guestproperty set "CentOS9Test" "/VirtualBox/GuestInfo/Net/0/V4/IP" "192.168.2.151"
VBoxManage guestproperty unset "CentOS9Test" "/VirtualBox/GuestInfo/Net/0/V4/IP"