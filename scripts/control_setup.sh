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
    # Kubernetes cluster initialization

    # initialize Kubernetes control plane
    sudo kubeadm config images pull

    # 1. initialize kubernetes cluster 
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16
    # 2. Start cluster 
    # 2.1 root
    export KUBECONFIG=/etc/kubernetes/admin.conf
    # 2.2 non-root
    mkdir -p $HOME/.kube
    sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    # 3. verify
    kubectl cluster-info
    # deploy a pod network
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
    # download manifest
    curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
    # adjust CIDR
    sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.244.0.0\/16/g' custom-resources.yaml
    # create Calico custom resources
    kubectl create -f custom-resources.yaml

    # verify
    kubectl get nodes

    # NOTE: In case of errors with kubeadm init, run below :
    yes | sudo kubeadm reset
    sudo rm -rf /etc/cni/net.d
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
    sudo rm -rf $HOME/.kube

    # -------------------------------

    # install keycloak helm chart (bitnami)
    helm install my-release oci://registry-1.docker.io/bitnamicharts/keycloak
    

}