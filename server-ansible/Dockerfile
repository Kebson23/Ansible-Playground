FROM debian:stable-slim

LABEL org.opencontainers.image.description="Ansible Server Based on the debian repo"

# Service account
ARG service_user=service_user
ARG service_uid=10000
ARG service_gid=10000
ENV project_dir=/data

#Runtime account
ENV shellinabox_USER="admin"
ENV  shellinabox_PORT="4200"
ENV shellinabox_USER_UID=20000
ENV shellinabox_USER_GID=20000


RUN DEBIAN_FRONTEND=noninteractive \
    apt update && apt --no-install-recommends install -y shellinabox sudo ansible openssh-server acl && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* /var/tmp/* && apt clean

RUN groupadd -g ${service_gid} ${service_user} && \
    useradd -u ${service_uid} -g ${service_gid} \
    -m -s /usr/sbin/nologin ${service_user} 

RUN --mount=type=secret,id=shellinabox_password \
    shellinabox_PASS="$(tr -d '\r\n' < /run/secrets/shellinabox_password)"; \
    groupadd -g ${shellinabox_USER_GID} ${shellinabox_USER} && \
    useradd -u ${shellinabox_USER_UID} -g ${shellinabox_USER_GID} \
    -m -s /bin/bash  ${shellinabox_USER} && \
    usermod -aG sudo ${shellinabox_USER} && \
    echo "${shellinabox_USER}:${shellinabox_PASS}" | chpasswd 

COPY --from=scripts running.sh /opt/running.sh
RUN chmod 755 /opt/running.sh

RUN --mount=type=secret,id=service_for_user \
    services="$(tr -d '\r\n' < /run/secrets/service_for_user)"; \
    echo "${services}" > /etc/sudoers.d/${service_user} && \
    chmod 440 /etc/sudoers.d/${service_user}

COPY --from=scripts ansible-preconf.py /tmp/ansible-preconf.py
RUN python3 /tmp/ansible-preconf.py && \
    rm -fr /tmp/ansible-preconf.py

RUN --mount=type=secret,id=shellinabox_password \
    mkdir -p ${project_dir} && \
    tr -dc 'A-Za-z0-9!@#%^*_+=-' < /dev/urandom \
    | head -c 20 \
    | sed 's/$/\n/' \
    > /data/vault_pass && \
    cp /run/secrets/shellinabox_password /${project_dir}/pass && \
    ansible-vault encrypt /${project_dir}/pass --vault-password-file /${project_dir}/vault_pass && \
    chmod 640 ${project_dir}/vault_pass  ${project_dir}/pass && \
    chown -R ${service_user}:${shellinabox_USER} ${project_dir}  

RUN echo 'set bell-style none' >> /etc/inputrc

EXPOSE ${shellinabox_PORT}
USER ${service_user}

WORKDIR ${project_dir}

ENTRYPOINT ["/bin/bash","/opt/running.sh"]
CMD []