


  # install wget
  yes | sudo dnf install wget >> $log_file_name
  wget --version >> $log_file_name
  
  # install virtualbox
  wget https://www.virtualbox.org/download/oracle_vbox_2016.asc >> $log_file_name
  sudo rpm --import oracle_vbox_2016.asc >> $log_file_name
  wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo >> $log_file_name
  yes | sudo dnf install VirtualBox-7.0 >> $log_file_name
  sudo dnf install -y "kernel-devel-$(uname -r)" >> $log_file_name
  sudo /sbin/vboxconfig >> $log_file_name
  VBoxManage list ostypes >> $log_file_name
  vboxmanage --version >> $log_file_name