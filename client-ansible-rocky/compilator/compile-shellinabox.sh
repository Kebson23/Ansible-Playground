#!/bin/bash
set -euo pipefail

check_os()
{
    if [ -f /etc/os-release ]; then
        . /etc/os-release
         OS_NAME=$ID
        if [[ "$OS_NAME" == "rocky" || "$OS_NAME" == "ol" ]]; then
            prepare_env
        else
            exit 1
        fi
    else 
        echo "Cannot determine operating system."
        exit 1
    fi  
}


prepare_env()
{
    OUTPUT=$(sudo microdnf install -y epel-release git openssl-devel pam-devel zlib-devel autoconf automake libtool gcc gcc-c++ make tar gzip 2>&1)

    if [ $? -eq 0 ]; then
        
        shellinabox=/tmp/shellinabox
        shellinabox_git="https://github.com/shellinabox/shellinabox.git --branch=v2.21 $shellinabox"
        git clone $shellinabox_git
        cd $shellinabox
        compilator
        sudo mkdir -p /var/lib/shellinabox
        sudo useradd -r shellinabox
        sudo chown shellinabox:shellinabox /var/lib/shellinabox
    else
        echo $OUTPUT > /tmp/logs.txt
        exit 1
    fi
}

compilator()
{
    autoreconf -i
    ./configure LIBS="-lssl -lcrypto" --prefix=/usr --bindir=/usr/bin
    sudo make
    sudo make install
}

clean_up()
{
    sudo microdnf remove -y \
    perl-Git \
    git \
    openssl-devel \
    pam-devel \
    zlib-devel \
    autoconf \
    automake \
    gcc \
    gcc-c++ \
    make \
    libtool
    sudo microdnf clean all -y 
    sudo rm -fr /tmp/* && sudo rm -fr /var/tmp/*
}

main()
{
    check_os
    clean_up
}

main