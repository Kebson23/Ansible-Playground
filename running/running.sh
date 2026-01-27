#!/bin/bash
set -euo pipefail

ENABLE_SSH=${ENABLE_SSH:-true}
ecdsa_key="/etc/ssh/ssh_host_ecdsa_key"
hostname_ansible_server="$HOSTNAME"


if [ "$ENABLE_SSH" = "true" ]; then
    if [ ! -f $ecdsa_key ]; then
        sudo ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
        sudo /usr/sbin/sshd -h /etc/ssh/ssh_host_ecdsa_key -E /var/log/ssh.log
    else
        sudo /usr/sbin/sshd -h /etc/ssh/ssh_host_ecdsa_key -E /var/log/ssh.log
    fi
fi

if [[ "$hostname_ansible_server" == "ansible-server" ]]; then 
    cd "${project_dir}" || exit 1
    PASS_FILE="${project_dir}/pass"
    VAULT_PASS_FILE="${project_dir}/vault_pass"
    ADMIN_PASS=$(ansible-vault view ${PASS_FILE} --vault-password-file ${VAULT_PASS_FILE})

    ANSIBLE_DIR="${project_dir}/ansible-playground"
    REQ_PERMISSION_ANSIBLE_DIR='755'
    CONF_ANSIBLE_FILE="${ANSIBLE_DIR}/ansible.cfg"
    REQ_PERMISSION_ANSIBLE_FILE='644'
    
    su admin -c "
    [[ \$(stat -c '%a' $ANSIBLE_DIR) != $REQ_PERMISSION_ANSIBLE_DIR ]]  && sudo -S chmod -R $REQ_PERMISSION_ANSIBLE_DIR $ANSIBLE_DIR <<< '$ADMIN_PASS'
    [[ \$(stat -c '%a' $CONF_ANSIBLE_FILE) != $REQ_PERMISSION_ANSIBLE_FILE ]]  && sudo -S chmod -R $REQ_PERMISSION_ANSIBLE_FILE $CONF_ANSIBLE_FILE <<< '$ADMIN_PASS'

    cd '${ANSIBLE_DIR}' || exit 1
    HOSTS_IN_INVENTORY_FILE=\$(ansible all --list-hosts | grep -oP 'hosts \(\K[0-9]+(?=\):)')
    if [ \"\$HOSTS_IN_INVENTORY_FILE\" -eq 0 ] || [ -z \"\$HOSTS_IN_INVENTORY_FILE\" ]; then
       exit 1
    fi

    if ! ansible all -m ping -o > /dev/null 2>&1; then
        export ANSIBLE_SSH_COMMON_ARGS='-o StrictHostKeyChecking=accept-new' && \
        ansible-playbook prerequisites/lab00.yml --vault-password-file ${VAULT_PASS_FILE} \
        --become-password-file ${PASS_FILE} --connection-password-file ${PASS_FILE} > /dev/null 2>&1
        
        PLAYBOOK_STATUS=\$?
        exit \$PLAYBOOK_STATUS
    
    else
        exit 0
    fi
" <<EOF
$ADMIN_PASS
EOF
    STATUS=$?
    if [ $STATUS -eq 0 ]; then 
        echo "Connection works propertly from ansible server to ansible client."
    else 
        echo "Check your ansible logs in dir '${ANSIBLE_DIR}/logs'"
    fi
fi

exec sudo /usr/bin/shellinaboxd --no-beep --user=${shellinabox_USER} --group=${shellinabox_USER} --port=${shellinabox_PORT} -q \
 -c /var/lib/shellinabox \
 --disable-ssl \
 --user-css "Normal:+/etc/shellinabox/options-enabled/00_White On Black.css;Colors:+/etc/shellinabox/options-enabled/01+Color Terminal.css"