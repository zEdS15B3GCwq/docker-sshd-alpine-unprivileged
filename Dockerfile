FROM alpine:latest
LABEL maintainer="fehervari.tamas@outlook.com"

ARG BUILD_DATE

LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.opencontainers.image.authors="fehervari.tamas@outlook.com"

ENV USER_UID=2000
ENV USER_GID=2000
ENV BACKUP_DIR="/backup"

EXPOSE 22
COPY entrypoint.sh /

RUN apk add --no-cache openssh && \
    # disable password login
    # sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

    # is /var/run/sshd really needed? works without
    # mkdir /var/run/sshd && \
    # chmod 0755 /var/run/sshd && \

ENTRYPOINT ["/entrypoint.sh"]
