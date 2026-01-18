FROM debian:trixie-slim

ARG shellinabox_USER
ARG shellinabox_PORT
ARG user_UID=20000
ARG group_GID=20000
ENV shellinabox_USER=${shellinabox_USER}
ENV shellinabox_PORT=${shellinabox_PORT}
ENV HOME=/home/${shellinabox_USER}

RUN DEBIAN_FRONTEND=noninteractive \
    apt update && apt --no-install-recommends install -y shellinabox sudo openssh-server python3 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* /var/tmp/* && apt clean



RUN --mount=type=secret,id=shellinabox_password \
    shellinabox_PASS="$(tr -d '\r\n' < /run/secrets/shellinabox_password)"; \
    useradd -m -s /bin/bash  ${shellinabox_USER} && \
    usermod -aG sudo ${shellinabox_USER} && \
    echo "${shellinabox_USER}:${shellinabox_PASS}" | chpasswd && \
    echo "${shellinabox_USER} ALL=(ALL) NOPASSWD: /usr/bin/shellinaboxd, /usr/sbin/sshd" > /etc/sudoers.d/${shellinabox_USER} && \
    chmod 440 /etc/sudoers.d/${shellinabox_USER}

COPY --from=scripts running.sh /opt/running.sh
RUN chmod +x /opt/running.sh

RUN echo 'set bell-style none' >> /etc/inputrc
EXPOSE ${shellinabox_PORT}
USER ${shellinabox_USER}

WORKDIR ${HOME}

ENTRYPOINT ["/bin/bash","/opt/running.sh"]
CMD []

