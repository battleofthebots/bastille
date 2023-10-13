FROM ghcr.io/battleofthebots/botb-base-image:latest AS builder

RUN apt-get update && \
    apt-get -y install libreadline-dev bc

# Compile bastille and cleanup
COPY main.c .
RUN gcc -o /bin/bastille main.c -DPRODUCTION -L/usr/include -lreadline

FROM ghcr.io/battleofthebots/botb-base-image:latest
# Update this with youe challenge name if you are pushing to a docker registry
ARG NAME=bastille
LABEL org.opencontainers.image.title=$NAME org.opencontainers.image.description=$NAME org.opencontainers.image.url=https://github.com/battleofthebots/$NAME org.opencontainers.image.source=https://github.com/battleofthebots/$NAME org.opencontainers.image.version=main
WORKDIR /opt

EXPOSE 22
# Bins they are allowed to have in jail 
# CWD for the jail
# Bin dir for the jail
ARG ALLOWED="echo awk tee bind mkdir xxd strings pwd ls fmt file dd bc make cp whoami su bastille cat"
ENV JAIL_CWD=/opt/cwd
ENV JAIL_BIN=/opt/bin

COPY release/build_jail.sh /opt
COPY --from=builder /bin/bc /bin/bc

# Build the jail and setup ssh with a random user password
RUN bash build_jail.sh && usermod user -s /bin/bastille -d $JAIL_CWD && \
    mkdir -p $JAIL_CWD /run/sshd && chmod 777 $JAIL_CWD && \
    chmod 700 /run/sshd && \
    ssh-keygen -A && \
    echo "user:password" | tee /dev/stderr | chpasswd && \
    echo "UsePAM no\nPermitTunnel no\nAcceptEnv LANG LC_*\nSetEnv JAIL_PATH=$JAIL_BIN" > /etc/ssh/sshd_config

COPY --from=builder /bin/bastille /bin/bastille
CMD /usr/sbin/sshd -D