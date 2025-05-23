## Create Centos9 VM base image (local)
1. install VirtualBox 7.1.4 (not 7.1.6)
2. enable VT-x or AMD-v
3. disable Hyper-V and WSL2 (Docker)
4. download Centos 9 ISO - https://mirrors.centos.org/mirrorlist?path=/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso
5. VirtualBox - Create VM
    > New
    - Name : CentOS9
    - Type : Linux
    - Version : Red Hat (64-bit)
    - Memory size : 2048
    - Create a virtual hard disk now
    - Hard disk file type : VDI
    - Storage on physical hard disk : Dynamically allocated
    - Hard disk size : 20 GB
    > Settings > System > Motherboard
    - Boot Order : Optical > Hard Disk
    > Settings > Storage
    - Controller : IDE > Empty - click
        - Attributes > Optical Drive - click > Choose a disk file > select ISO > Open
    > Start
    > OS Installation
    - Test this media & install CentOS Stream 9
    - Select language
    - Select Root Password
    - Select Installation Destination
    - Select Software Selection
        - Minimal Install
    - Select User Creation
    - Begin Installation
    - Reboot System
    > Stop VM
    > Settings > System > Motherboard
    - Boot Order : Hard Disk
    > Start VM
    > Test Login
    > Stop VM
    > Close VirtualBox
6. VirtualBox - Configure Vm
    > Settings > Storage
    - Controller : IDE > disk - click
        - Attributes > Optical Drive - click > Remove disk from virtual drive
    > Settings > Network > Adapter 1
        - Attached to : Bridged Adapter
        - Promiscuous Mode : Allow All
    > Start VM
    > Login
    > Get IP (terminal)
        - ip addr show
    > login to VM from putty
        - run scripts/common_setup.sh
7. VirtualBox - Export Vm
    > File > Export Virtual Appliance
    - Virtual machines : CentOS9
    - Format settings > Format : Open Virtualization Format 1.0
    - Select Write Manifest File
    - Select Include ISO Image Files
    - Finish