#!/bin/bash
set -euo pipefail

ENABLE_SSH=${ENABLE_SSH:-true}
ecdsa_key="/etc/ssh/ssh_host_ecdsa_key"

if [ "$ENABLE_SSH" = "true" ]; then
    if [ ! -f $ecdsa_key ]; then
        sudo ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
        sudo /usr/sbin/sshd -h /etc/ssh/ssh_host_ecdsa_key -E /var/log/ssh.log
    else
        sudo /usr/sbin/sshd -h /etc/ssh/ssh_host_ecdsa_key -E /var/log/ssh.log
    fi
fi


exec sudo /usr/bin/shellinaboxd --no-beep --user=${shellinabox_USER} --group=${shellinabox_USER} --port=${shellinabox_PORT} -q \
 -c /var/lib/shellinabox \
 --disable-ssl \
 --user-css "Normal:+/etc/shellinabox/options-enabled/00_White On Black.css;Colors:+/etc/shellinabox/options-enabled/01+Color Terminal.css"
