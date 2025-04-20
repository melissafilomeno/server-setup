#!/bin/bash

readonly log_file_name="stop_vm.sh.log"
VM_NAME=$1

# stop VM 
VBoxManage controlvm "$VM_NAME" poweroff >> $log_file_name

return 0