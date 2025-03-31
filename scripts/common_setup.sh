#!/bin/bash

# Common installation :
install_common_apps(){

    local LOG_FILE_NAME = "$1"

    sudo su
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
    
    # install kubernetes
    # 1. disable swap
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab >> $LOG_FILE_NAME
    sudo swapoff -a >> $LOG_FILE_NAME
    # 2. disable SELINUX
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
    # 3. install kubernetes
    sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes >> $LOG_FILE_NAME
    kubectl version >> $LOG_FILE_NAME
    kubeadm version >> $LOG_FILE_NAME
    sudo systemctl enable --now kubelet >> $LOG_FILE_NAME
    systemctl start kubelet >> $LOG_FILE_NAME

}