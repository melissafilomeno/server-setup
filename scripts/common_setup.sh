#!/bin/bash

# Common installation :
install_common_apps(){

    local LOG_FILE_NAME = "$1"

    dnf update

    # install jdk 17
    yes | sudo dnf install java-17-openjdk.x86_64 >> $LOG_FILE_NAME
    java --version >> $LOG_FILE_NAME

    # install git
    yes | sudo dnf install git >> $LOG_FILE_NAME
    git --version >> $LOG_FILE_NAME

    # install wget
    yes | sudo dnf install wget >> $LOG_FILE_NAME
    wget --version >> $LOG_FILE_NAME

    # install virtualbox
    wget https://www.virtualbox.org/download/oracle_vbox_2016.asc >> $LOG_FILE_NAME
    sudo rpm --import oracle_vbox_2016.asc >> $LOG_FILE_NAME
    wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo >> $LOG_FILE_NAME
    yes | sudo dnf install VirtualBox-7.0 >> $LOG_FILE_NAME
    sudo dnf install -y "kernel-devel-$(uname -r)" >> $LOG_FILE_NAME
    sudo /sbin/vboxconfig >> $LOG_FILE_NAME
    VBoxManage list ostypes >> $LOG_FILE_NAME

    # -----------------------------
    # install kubernetes

    # Add kernel modules (communication)
    sudo modprobe br_netfilter
    sudo modprobe ip_vs
    sudo modprobe ip_vs_rr
    sudo modprobe ip_vs_wrr
    sudo modprobe ip_vs_sh
    sudo modprobe overlay

    # add modules
cat > /etc/modules-load.d/kubernetes.conf << EOF
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF

    # configure sysctl
    cat > /etc/sysctl.d/kubernetes.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

    # reboot sysctl
    sudo sysctl --system
    
    # disable swap
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab >> $LOG_FILE_NAME
    sudo swapoff -a >> $LOG_FILE_NAME

    # add repo for docker CE packages
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> $LOG_FILE_NAME

    # update package cache
    sudo dnf makecache

    # install containerd.io package
    sudo dnf -y install containerd.io

    # configure containerd
    sudo sh -c "containerd config default > /etc/containerd/config.toml" ; cat /etc/containerd/config.toml
    # [MANUAL] update [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options] > SystemdCgroup = true
    vi /etc/containerd/config.toml
    # start and enable containerd on reboot
    sudo systemctl enable --now containerd.service
    
    # reboot
    sudo systemctl reboot

    # [MANUAL] relogin

    # check containerd status
    sudo systemctl status containerd.service

    # disable SELINUX 
    # [TODO] undo and retest
    sudo setenforce 0 >> $LOG_FILE_NAME
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config >> $LOG_FILE_NAME
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF >> $LOG_FILE_NAME

    # set firewall rules
    # [TODO] run after enabling SELINUX
    sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10251/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10252/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10255/tcp
sudo firewall-cmd --zone=public --permanent --add-port=5473/tcp
    # reload firewall
    # [TODO] run after enabling SELINUX
    sudo firewall-cmd --reload

    # install kubernetes
    sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes >> $LOG_FILE_NAME
    kubectl version >> $LOG_FILE_NAME
    kubeadm version >> $LOG_FILE_NAME
    sudo systemctl enable --now kubelet >> $LOG_FILE_NAME
    systemctl start kubelet >> $LOG_FILE_NAME

}