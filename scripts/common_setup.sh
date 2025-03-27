#!/bin/bash

# Common installation :
install_common_apps(){
    # install jdk 17
    yes | sudo dnf install java-17-openjdk.x86_64 >> setup.sh.log
    java --version >> setup.sh.log

    # install git
    yes | sudo dnf install git >> setup.sh.log
    git --version >> setup.sh.log
}

exit 0