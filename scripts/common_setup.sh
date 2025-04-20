#!/bin/bash

# Common installation :
_install_common_apps(){

  local log_file_name = "$1"
  
  yes | sudo dnf update
  
  # check ssh
  sudo dnf install openssh-clients openssh-server

  # -----------------------------
  # install kubernetes
  
  # Add kernel modules (communication)
  sudo modprobe br_netfilter >> $log_file_name
  sudo modprobe ip_vs >> $log_file_name
  sudo modprobe ip_vs_rr >> $log_file_name
  sudo modprobe ip_vs_wrr >> $log_file_name
  sudo modprobe ip_vs_sh >> $log_file_name
  sudo modprobe overlay >> $log_file_name

# add modules
cat > /etc/modules-load.d/kubernetes.conf << EOF
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF >> $log_file_name

    # configure sysctl
cat > /etc/sysctl.d/kubernetes.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1vol
EOF >> $log_file_name

    # reboot sysctl
    sudo sysctl --system >> $log_file_name
    
    # disable swap
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab >> $log_file_name
    sudo swapoff -a >> $log_file_name

    # add repo for docker CE packages
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> $log_file_name

    # update package cache
    sudo dnf makecache >> $log_file_name

    # install containerd.io package
    sudo dnf -y install containerd.io >> $log_file_name

    # configure containerd
    sudo sh -c "containerd config default > /etc/containerd/config.toml" ; cat /etc/containerd/config.toml >> $log_file_name
    # [MANUAL] update [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options] > SystemdCgroup = true
    vi /etc/containerd/config.toml
    # start and enable containerd on reboot
    sudo systemctl enable --now containerd.service >> $log_file_name
    
    # reboot
    sudo systemctl reboot >> $log_file_name

    # [MANUAL] relogin

    # check containerd status
    sudo systemctl status containerd.service >> $log_file_name

    # start firewalld
    sudo systemctl start firewalld >> $log_file_name
    # enable firewalld at startup
    sudo systemctl enable firewalld >> $log_file_name
    # check firewall state
    firewall-cmd --state >> $log_file_name
    # check firewall status
    systemctl status firewalld >> $log_file_name
    # firewall rules
    sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp >> $log_file_name
    sudo firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp >> $log_file_name
    sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp >> $log_file_name
    sudo firewall-cmd --zone=public --permanent --add-port=10251/tcp >> $log_file_name
    sudo firewall-cmd --zone=public --permanent --add-port=10252/tcp >> $log_file_name
    sudo firewall-cmd --zone=public --permanent --add-port=10255/tcp >> $log_file_name
    sudo firewall-cmd --zone=public --permanent --add-port=5473/tcp >> $log_file_name
    # reload firewall
    sudo firewall-cmd --reload >> $log_file_name

    # add kubernetes repository
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF >> $log_file_name

    # install kubernetes
    sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes >> $log_file_name
    kubectl version >> $log_file_name
    kubeadm version >> $log_file_name

    # enable kubelet service
    sudo systemctl enable --now kubelet >> $log_file_name
    systemctl start kubelet >> $log_file_name

}