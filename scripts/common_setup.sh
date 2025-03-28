#!/bin/bash

# Common installation :
install_common_apps(){

    sudo su
    dnf update

    # install jdk 17
    yes | sudo dnf install java-17-openjdk.x86_64 >> setup.sh.log
    java --version >> setup.sh.log

    # install git
    yes | sudo dnf install git >> setup.sh.log
    git --version >> setup.sh.log

    # install wget
    yes | sudo dnf install wget >> setup.sh.log
    wget --version >> setup.sh.log

    # install virtualbox
    wget https://www.virtualbox.org/download/oracle_vbox_2016.asc >> setup.sh.log
    sudo rpm --import oracle_vbox_2016.asc >> setup.sh.log
    wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo >> setup.sh.log
    yes | sudo dnf install VirtualBox-7.0 >> setup.sh.log
    sudo dnf install -y "kernel-devel-$(uname -r)" >> setup.sh.log
    sudo /sbin/vboxconfig >> setup.sh.log
    VBoxManage list ostypes >> setup.sh.log
    
    # install kubernetes
    sudo setenforce 0 >> setup.sh.log
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config >> setup.sh.log
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
    enabled=1
    gpgcheck=1
    gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
    exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
    EOF
    sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes >> setup.sh.log

    # install docker
    sudo dnf -y install dnf-plugins-core >> setup.sh.log
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> setup.sh.log
    yes | sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> setup.sh.log
    sudo systemctl enable --now docker >> setup.sh.log
    sudo docker run hello-world >> setup.sh.log

    # install cri-dockerd (manual)
    # 1 - install golang
    wget https://go.dev/dl/go1.24.1.linux-amd64.tar.gz
    tar zxvf go1.24.1.linux-amd64.tar.gz
    sudo mv go /usr/lib/golang
    sudo ln -s /usr/lib/golang/bin/go /usr/bin/go
    go version
    # 2 - install cri-dockerd
    git clone https://github.com/Mirantis/cri-dockerd.git
    cd cri-dockerd && \
    make cri-dockerd
    cd cri-dockerd && \
    mkdir -p /usr/local/bin && \
    install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd && \
    install packaging/systemd/* /etc/systemd/system && \
    sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
    sudo systemctl daemon-reload && \
    sudo systemctl enable --now cri-docker
    sudo systemctl daemon-reload && \
    sudo systemctl restart cri-docker
    systemctl status cri-docker
    cri-dockerd --version

    exit 0

}