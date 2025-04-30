#!/bin/bash

readonly log_file_name="create_vm.sh.log"
VM_NAME=$1
EXPORTED_FILE_NAME=$2

# import VM
# dry-run (shows defaults and configurable options)
VBoxManage import "$EXPORTED_FILE_NAME" --vsys 0 --vmname "$VM_NAME" --ostype Fedora_64 --memory 2048 --dry-run >> $log_file_name
# or final
VBoxManage import "$EXPORTED_FILE_NAME" --vsys 0 --vmname "$VM_NAME" --ostype Fedora_64 --memory 2048 >> $log_file_name

# show VM details
VBoxManage showvminfo "$VM_NAME" >> $log_file_name

# configure bridged networking
ifconfig
VBoxManage modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 enp3s0 --nic-promisc1=allow-all >> $log_file_name

# disable audio
VBoxManage modifyvm "$VM_NAME" --audio-driver none >> $log_file_name

# check processor information (intel)
lscpu
# disable KVM kernel extension
sudo modprobe -r kvm-intel >> $log_file_name

# start VM (shows more logs)
VBoxHeadless --startvm "$VM_NAME" >> $log_file_name
# or run in the background
VBoxManage startvm "$VM_NAME" --type headless >> $log_file_name

return 0