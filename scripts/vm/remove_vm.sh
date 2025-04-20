#!/bin/bash

readonly log_file_name="remove_vm.sh.log"
VM_NAME=$1

# delete VM
VBoxManage unregistervm "$VM_NAME" --delete >> $log_file_name

return 0