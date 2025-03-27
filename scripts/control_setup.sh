#!/bin/bash

source common_setup

install_common_apps
install_control_node_apps

# Control Node specific
install_control_node_apps(){
    #install python3
    sudo dnf install python3 >> setup.sh.log
    python --version >> setup.sh.log

    #install pip3
    yes | sudo dnf install python3-pip >> setup.sh.log
    pip --version >> setup.sh.log

    #install ansible
    sudo pip install ansible >> setup.sh.log
    ansible --version >> setup.sh.log

    # install ansible-core
    sudo pip install ansible-core >> setup.sh.log

    # install maven
    yes | sudo dnf install maven >> setup.sh.log
    mvn --version >> setup.sh.log
}

return 0;