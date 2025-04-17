# install docker
sudo dnf -y install dnf-plugins-core >> $LOG_FILE_NAME
yes | sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> $LOG_FILE_NAME
sudo systemctl enable --now docker >> $LOG_FILE_NAME
sudo docker run hello-world >> $LOG_FILE_NAME
# ------------------------------------------
# uninstall docker
# stop docker services
sudo systemctl stop docker
# uninstall docker
yes | sudo dnf remove docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin
# delete docker data directories
sudo rm -rf /var/lib/docker

# install cri-dockerd (manual)
# 1 - install golang
wget https://go.dev/dl/go1.24.1.linux-amd64.tar.gz >> $LOG_FILE_NAME
tar zxvf go1.24.1.linux-amd64.tar.gz >> $LOG_FILE_NAME
sudo mv go /usr/lib/golang >> $LOG_FILE_NAME
sudo ln -s /usr/lib/golang/bin/go /usr/bin/go >> $LOG_FILE_NAME
go version >> $LOG_FILE_NAME
# 2 - install cri-dockerd
git clone https://github.com/Mirantis/cri-dockerd.git >> $LOG_FILE_NAME
cd cri-dockerd && \
make cri-dockerd
cd cri-dockerd && \
mkdir -p /usr/local/bin && \
install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd && \
install packaging/systemd/* /etc/systemd/system && \
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service >> $LOG_FILE_NAME
sudo systemctl daemon-reload && \
sudo systemctl enable --now cri-docker >> $LOG_FILE_NAME
sudo systemctl daemon-reload && \
sudo systemctl restart cri-docker >> $LOG_FILE_NAME
cri-dockerd --version >> $LOG_FILE_NAME
# 3 - configure cri-dockerd
sudo kubeadm config images pull --cri-socket unix:///var/run/cri-dockerd.sock >> $LOG_FILE_NAME
#--------------------------------------------------------
# uninstall cri-dockerd
# Disable cri-dockerd
sudo systemctl disable --now cri-docker.service
# stop cri-docker.service
sudo systemctl stop cri-docker.service
# remove cri-dockerd
sudo rm -rf /etc/systemd/system/cri-docker.service

#---------------------------------------------------------------
# Kubernetes cluster initialization (cri-dockerd)
# 1. initialize kubernetes cluster 
sudo kubeadm init --cri-socket unix:///var/run/cri-dockerd.sock
# In case of errors with kubeadm init, run below :
yes | sudo kubeadm reset --cri-socket unix:///var/run/cri-dockerd.sock
# ----------------------

# disable SELINUX 
sudo setenforce 0 >> $LOG_FILE_NAME
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config >> $LOG_FILE_NAME
#----------------------------------------------------------------
# undo disabling SELINUX
# get SELINUX state
getenforce
# check current config
cat /etc/selinux/config
# enable SELINUX (where disabled = current state)
sudo sed -i 's/^SELINUX=disabled$/SELINUX=enforcing/' /etc/selinux/config
# [MANUAL] reboot
# enable SELINUX
sudo setenforce 1

#---------------------------------------------------------------
# create VM
VBoxManage createvm --name Centos9Test --ostype Fedora_64 --register

# download Centos 9 iso
wget https://mirrors.centos.org/mirrorlist?path=/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso
# or copy file

# connect VM drive to host drive
VBoxManage storageattach Centos9Test --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$HOME_DIR/CentOS-Stream-9-latest-x86_64-dvd1.iso"
VBoxManage showvminfo Centos9Test | grep "IDE Controller"
