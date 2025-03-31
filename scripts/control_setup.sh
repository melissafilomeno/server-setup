#!/bin/bash

source common_setup

readonly LOG_FILE_NAME="control_setup.sh.log"

install_common_apps $LOG_FILE_NAME
install_control_node_apps

return 0;

# Control Node specific
install_control_node_apps(){
    #install python3
    sudo dnf install python3 >> $LOG_FILE_NAME
    python --version >> $LOG_FILE_NAME

    #install pip
    yes | sudo dnf install python3-pip >> $LOG_FILE_NAME
    pip --version >> $LOG_FILE_NAME

    #install ansible
    sudo pip install ansible >> $LOG_FILE_NAME
    ansible --version >> $LOG_FILE_NAME

    # install ansible-core
    sudo pip install ansible-core >> $LOG_FILE_NAME

    # install maven
    yes | sudo dnf install maven >> $LOG_FILE_NAME
    mvn --version >> $LOG_FILE_NAME

    # install helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 >> $LOG_FILE_NAME
    chmod 700 get_helm.sh >> $LOG_FILE_NAME
    helm version >> $LOG_FILE_NAME

    #----------------------------------------
    # Kubernetes cluster initialization (containerd)

    # prevent issue creating CRI runtime service
    rm -f /etc/containerd/config.toml
    systemctl restart containerd

    # IPv4 Forwarding
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
    # 5. Overlay network and bridge netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
    sudo modprobe overlay
    sudo modprobe br_netfilter
    # reboot sysctl
    sudo sysctl --system

    #Remove cri-dockerd
    sudo systemctl disable --now cri-docker

    # 1. initialize kubernetes cluster 
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16
    # 2. Start cluster 
    export KUBECONFIG=/etc/kubernetes/admin.conf
    # 3. verify
    kubectl cluster-info

    # NOTE: In case of errors with kubeadm init, run below :
    yes | sudo kubeadm reset
    sudo rm -rf /etc/cni/net.d
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
    sudo rm -rf $HOME/.kube

    # -------------------------------

    # install keycloak helm chart (bitnami)
    helm install my-release oci://registry-1.docker.io/bitnamicharts/keycloak
    

}