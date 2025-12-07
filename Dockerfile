FROM debian:trixie-slim

ARG shellinabox_USER
ARG shellinabox_PORT
ENV shellinabox_USER=${shellinabox_USER}
ENV shellinabox_PORT=${shellinabox_PORT}


RUN apt update && apt --no-install-recommends install -y shellinabox sudo && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* /var/tmp/* && apt clean



RUN --mount=type=secret,id=shellinabox_password_user,env=shellinabox_PASS \
    useradd -m ${shellinabox_USER} && \
    usermod -aG sudo ${shellinabox_USER} && \
    echo "${shellinabox_USER}:${shellinabox_PASS}" | chpasswd && \
    echo "${shellinabox_USER} ALL=(ALL) NOPASSWD: /usr/bin/shellinaboxd" >> /etc/sudoers && \
    mv "/etc/shellinabox/options-enabled/00_White On Black.css" "/etc/shellinabox/options-enabled/00_WhiteOnBlack.css" 

EXPOSE ${shellinabox_PORT}
USER ${shellinabox_USER}

CMD ["bash","-c","sudo /usr/bin/shellinaboxd --no-beep --user=${shellinabox_USER} --group=${shellinabox_USER} --port=${shellinabox_PORT} --css=/etc/shellinabox/options-enabled/00_WhiteOnBlack.css --disable-ssl"]




