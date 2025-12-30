FROM rockylinux:9-minimal

ARG shellinabox_USER
ARG shellinabox_PORT
ARG user_UID=30000
ARG group_GID=30000
ENV shellinabox_USER=${shellinabox_USER}
ENV shellinabox_PORT=${shellinabox_PORT}
ENV HOME=/home/${shellinabox_USER}

RUN microdnf install epel-release -y && \
    microdnf install sudo openssh-server python -y

COPY compilator/compile-shellinabox.sh /opt/compile-shellinabox.sh
RUN chmod +x /opt/compile-shellinabox.sh && ./opt/compile-shellinabox.sh

RUN --mount=type=secret,id=shellinabox_password,env=shellinabox_PASS \
    useradd -m -s /bin/bash ${shellinabox_USER} && \
    usermod -aG wheel ${shellinabox_USER} && \
    echo "${shellinabox_USER}:${shellinabox_PASS}" | chpasswd && \
    echo "${shellinabox_USER} ALL=(ALL) NOPASSWD: /usr/bin/shellinaboxd, /usr/sbin/sshd,/usr/bin/ssh-keygen" > /etc/sudoers.d/${shellinabox_USER} && \
    chmod 440 /etc/sudoers.d/${shellinabox_USER}


COPY --from=scripts running.sh /opt/running.sh
RUN chmod +x /opt/running.sh

COPY shellinabox-css/00_White_On_Black.css /etc/shellinabox/options-enabled/00_White_on_Black.css
COPY  shellinabox-css/01_Color_Terminal.css /etc/shellinabox/options-enabled/01_Color_Terminal.css
RUN mv /etc/shellinabox/options-enabled/00_White_on_Black.css "/etc/shellinabox/options-enabled/00_White On Black.css" && \
    mv /etc/shellinabox/options-enabled/01_Color_Terminal.css "/etc/shellinabox/options-enabled/01+Color Terminal.css"




RUN echo 'set bell-style none' >> /etc/inputrc
EXPOSE ${shellinabox_PORT}
USER ${shellinabox_USER}

WORKDIR ${HOME}

ENTRYPOINT ["/opt/running.sh"]
CMD []



