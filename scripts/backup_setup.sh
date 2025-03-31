    # install docker
    sudo dnf -y install dnf-plugins-core >> $LOG_FILE_NAME
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> $LOG_FILE_NAME
    yes | sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> $LOG_FILE_NAME
    sudo systemctl enable --now docker >> $LOG_FILE_NAME
    sudo docker run hello-world >> $LOG_FILE_NAME

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

    # Kubernetes cluster initialization (cri-dockerd)
    # 1. initialize kubernetes cluster 
    sudo kubeadm init --cri-socket unix:///var/run/cri-dockerd.sock

    # In case of errors with kubeadm init, run below :
    yes | sudo kubeadm reset --cri-socket unix:///var/run/cri-dockerd.sock
