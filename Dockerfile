FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="America/New_York"

RUN apt-get update && \
    apt-get -y install python3 python3-pip build-essential nmap netcat curl wget vim iproute2 ftp iputils-ping && \
    pip install requests && \
    mkdir /flags/ && chmod 777 /flags

WORKDIR /opt

RUN apt-get update && \
    apt-get install -y bc libreadline-dev openssh-server

# Password for sshd is one of these
COPY rockyou15.txt /tmp

# Bins they are allowed to have in jail AWK is the escape trick here, see GTFO bins, they can also escape using SSH
# CWD for the jail
# Bin dir for the jail
ARG ALLOWED="echo sed tee bind mkdir pwd ls fmt file dd bc make cp whoami su bastille cat"
ARG JAIL_CWD=/opt/cwd
ARG JAIL_BIN=/opt/bin


# Build the jail and setup ssh  with a random user password
RUN mkdir -p $JAIL_BIN $JAIL_CWD; for i in $ALLOWED; do ln -s $(which $i) $JAIL_BIN/$i; done && \
    echo "#!/bin/sh\necho You are not allowed to ssh!" > /opt/bin/ssh && \
    chmod +x /opt/bin/ssh && \
    chmod 555 $JAIL_BIN && \
    chmod 777 $JAIL_CWD && \
# SSHD stuff
    useradd user -s /bin/bastille -d $JAIL_CWD && \
    mkdir -p /run/sshd && \
    chmod 700 /run/sshd && \
    ssh-keygen -A && \
    echo "user:$(shuf -n 1 /tmp/rockyou15.txt)" | tee /dev/stderr | chpasswd && \
    echo 'MaxAuthTries 5\nUsePAM no\nPermitTunnel no\nAcceptEnv LANG LC_*' > /etc/ssh/sshd_config


ENV PAGER=cat
# Compile bastille and cleanup
COPY main.c /opt
RUN gcc -o /bin/bastille main.c -L/usr/include -lreadline && rm -v main.c /tmp/rockyou15.txt
CMD /usr/sbin/sshd -D