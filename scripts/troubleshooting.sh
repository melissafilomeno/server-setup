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