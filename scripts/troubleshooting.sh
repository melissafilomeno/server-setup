# check kubelet config
cat /var/lib/kubelet/config.yaml
kubectl config view

# check kubelet status
systemctl status kubelet

# check kubelet logs 
journalctl -xeu kubelet

# check cluster 
kubectl cluster-info

# check logs
cd /var/log/containers
cat <log_file>

# list all pods
kubectl get pods
kubectl get pods --all-namespaces

# list helm releases
helm list -n <release_name>

# check containerd status
 sudo service containerd status

# troubleshoot start
 kubectl cluster-info dump

 # check kubectl config
 kubectl config view

 