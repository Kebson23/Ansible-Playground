FROM rockylinux:9-minimal AS builder

COPY compilator/compile-shellinabox.sh /opt/compile-shellinabox.sh
RUN chmod +x /opt/compile-shellinabox.sh && ./opt/compile-shellinabox.sh

FROM rockylinux:9-minimal

LABEL org.opencontainers.image.description="Ansible Client node Based on the rockylinux repo"

# Service account
ARG service_user=service_user
ARG service_uid=10000
ARG service_gid=10000

#Runtime account
ENV shellinabox_USER="admin"
ENV  shellinabox_PORT="4200"
ENV shellinabox_USER_UID=20000
ENV shellinabox_USER_GID=20000


RUN microdnf install epel-release -y && \
    microdnf install sudo openssh-server python -y && \
    microdnf clean all -y && \
    rm -fr /tmp/* && rm -fr /var/tmp/*

RUN groupadd -g ${service_gid} ${service_user} && \
    useradd -u ${service_uid} -g ${service_gid} \
    -s /usr/sbin/nologin ${service_user}

RUN --mount=type=secret,id=shellinabox_password \
    shellinabox_PASS="$(tr -d '\r\n' < /run/secrets/shellinabox_password)"; \
    groupadd -g ${shellinabox_USER_GID} ${shellinabox_USER} && \
    useradd -u ${shellinabox_USER_UID} -g ${shellinabox_USER_GID} \
    -m -s /bin/bash  ${shellinabox_USER} && \
    usermod -aG wheel ${shellinabox_USER} && \
    echo "${shellinabox_USER}:${shellinabox_PASS}" | chpasswd 

COPY --from=builder /usr/bin/shellinaboxd /usr/bin/shellinaboxd
COPY --from=builder /var/lib/shellinabox /var/lib/shellinabox

COPY --from=scripts running.sh /opt/running.sh
RUN chmod 755 /opt/running.sh

COPY shellinabox-css/00_White_On_Black.css /etc/shellinabox/options-enabled/00_White_on_Black.css
COPY  shellinabox-css/01_Color_Terminal.css /etc/shellinabox/options-enabled/01_Color_Terminal.css
RUN mv /etc/shellinabox/options-enabled/00_White_on_Black.css "/etc/shellinabox/options-enabled/00_White On Black.css" && \
    mv /etc/shellinabox/options-enabled/01_Color_Terminal.css "/etc/shellinabox/options-enabled/01+Color Terminal.css"

RUN --mount=type=secret,id=service_for_user_rocky \
    services="$(tr -d '\r\n' < /run/secrets/service_for_user_rocky)"; \
    echo "${services}" > /etc/sudoers.d/${service_user} && \
    chmod 440 /etc/sudoers.d/${service_user}

RUN echo 'set bell-style none' >> /etc/inputrc
EXPOSE ${shellinabox_PORT}
USER ${service_user}

ENTRYPOINT ["/bin/bash","/opt/running.sh"]
CMD []