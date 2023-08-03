# Dockerfile to be released to the competitor
FROM ghcr.io/battleofthebots/botb-base-image:latest
EXPOSE 22
WORKDIR /opt
ARG ALLOWED="echo awk tee bind mkdir xxd strings pwd ls fmt file dd make cp whoami su cat"
ENV JAIL_CWD=/opt/cwd
ENV JAIL_BIN=/opt/bin

COPY build_jail.sh /opt

# Build the jail and setup ssh
RUN bash build_jail.sh && usermod user -s /bin/bastille -d $JAIL_CWD && \
    mkdir -p $JAIL_CWD /run/sshd && chmod 777 $JAIL_CWD && \
    chmod 700 /run/sshd && \
    ssh-keygen -A && \
    echo "user:password" | tee /dev/stderr | chpasswd && \
    echo "UsePAM no\nPermitTunnel no\nAcceptEnv LANG LC_*\nSetEnv JAIL_PATH=$JAIL_BIN\nPermitTTY no" > /etc/ssh/sshd_config

COPY bastille /bin/bastille
CMD /usr/sbin/sshd -D
