FROM debian:trixie-slim

RUN apt update && apt dist-upgrade && apt install -y shellinabox sudo && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean && rm -fr /tmp/* /var/tmp/*

ENV shellinabox_USER=admin
ENV shellinabox_PASS=admin
ENV shellinabox_port=4200


RUN useradd -m ${shellinabox_USER} && \
    usermod -aG sudo ${shellinabox_USER} && \
    echo "${shellinabox_USER}:${shellinabox_PASS}" | chpasswd && \
    echo "admin ALL=(ALL) NOPASSWD: /usr/bin/shellinaboxd" >> /etc/sudoers && \
    mv "/etc/shellinabox/options-enabled/00_White On Black.css" "/etc/shellinabox/options-enabled/00_WhiteOnBlack.css" 

EXPOSE ${shellinabox_port}
USER ${shellinabox_USER}

CMD ["bash", "-c","sudo /usr/bin/shellinaboxd --no-beep --user=${shellinabox_USER} --group=${shellinabox_USER} --port=${shellinabox_port} --css=/etc/shellinabox/options-enabled/00_WhiteOnBlack.css --disable-ssl"]





