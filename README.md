# server-setup

Scripts for installing apps

## Setup
1. Copy scripts in /scripts to server
2. Run : export PATH=/usr/local/bin:$PATH
3. Run : sudo su
4. Run : ./setup.sh or ./control_setup.sh

## Create Centos9 VM
1. Complete steps in [this](/docs/create_vm.md) page
2. Copy CentOS9.ova to HOME_DIR
3. Run ./vm/create_vm.sh <VM_NAME>

## Checklist
- [x] Java 17
- [x] Git
- [x] Maven
- [x] Ansible
- [x] VirtualBox
- [x] Kubernetes
- [x] helm
- [ ] Keycloak + vault
- [ ] MySql
- [ ] Jenkins
- [ ] Jenkins Git plugin
- [ ] Jenkins Ansible plugin
- [ ] Nexus
- [ ] ES
- [ ] Logstash
- [ ] Kibana
- [ ] Mailu

