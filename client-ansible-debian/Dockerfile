FROM debian:stable-slim

LABEL org.opencontainers.image.description="Ansible Client node Based on the debian repo"

# Service account
ARG service_user=service_user
ARG service_uid=10000
ARG service_gid=10000

#Runtime account
ENV shellinabox_USER="admin"
ENV  shellinabox_PORT="4200"
ENV shellinabox_USER_UID=20000
ENV shellinabox_USER_GID=20000

RUN DEBIAN_FRONTEND=noninteractive \
    apt update && apt --no-install-recommends install -y shellinabox sudo openssh-server python3 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* /var/tmp/* && apt clean

RUN groupadd -g ${service_gid} ${service_user} && \
    useradd -u ${service_uid} -g ${service_gid} \
    -s /usr/sbin/nologin ${service_user}

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

RUN echo 'set bell-style none' >> /etc/inputrc
EXPOSE ${shellinabox_PORT}
USER ${service_user}


ENTRYPOINT ["/bin/bash","/opt/running.sh"]
CMD []