FROM rockylinux:8-minimal

ARG shellinabox_USER
ARG shellinabox_PORT
ARG user_UID=30000
ARG group_GID=30000
ENV shellinabox_USER=${shellinabox_USER}
ENV shellinabox_PORT=${shellinabox_PORT}
ENV HOME=/home/${shellinabox_USER}

RUN microdnf install -y epel-release && \
    microdnf install -y shellinabox sudo  && \
    microdnf clean all && \
    rm -fr /tmp/* /var/tmp/*


RUN --mount=type=secret,id=shellinabox_password,env=shellinabox_PASS \
    groupadd -g ${group_GID} ${shellinabox_USER} && \
    useradd --uid ${user_UID} --gid ${group_GID} --home-dir=${HOME} --create-home ${shellinabox_USER} && \
    usermod -aG sudo ${shellinabox_USER} && \
    echo "${shellinabox_USER}:${shellinabox_PASS}" | chpasswd && \
    echo "${shellinabox_USER} ALL=(ALL) NOPASSWD: /usr/bin/shellinaboxd" > /etc/sudoers.d/${shellinabox_USER} && \
    chmod 440 /etc/sudoers.d/${shellinabox_USER} && \
    mv "/etc/shellinabox/options-enabled/00_White On Black.css" "/etc/shellinabox/options-enabled/00_WhiteOnBlack.css" 

COPY --from=scripts running.sh /opt/running.sh
RUN chmod +x /opt/running.sh

EXPOSE ${shellinabox_PORT}
USER ${shellinabox_USER}

WORKDIR ${HOME}

ENTRYPOINT ["/opt/running.sh"]
CMD []



