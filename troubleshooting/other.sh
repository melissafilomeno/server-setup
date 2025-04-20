# ============ Containerd ==============

# check containerd status
 sudo service containerd status

 # ============= Helm =====================

# list helm releases
helm list -n <release_name>

# =============== Firewall ==========

# get zones
firewall-cmd --get-zones

# get all active zones
firewall-cmd --get-active-zones

# inspect public zone config
firewall-cmd --zone=public --list-all