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

# Bins they are allowed to have in jail 
# CWD for the jail
# Bin dir for the jail
ARG ALLOWED="echo awk tee bind mkdir xxd strings pwd ls fmt file dd bc make cp whoami su bastille cat"
ARG JAIL_CWD=/opt/cwd
ARG JAIL_BIN=/opt/bin


# Build the jail and setup ssh with a random user password
RUN useradd user -s /bin/bastille -d $JAIL_CWD && \
    mkdir -p /run/sshd && \
    chmod 700 /run/sshd && \
    ssh-keygen -A && \
    echo "user:password" | tee /dev/stderr | chpasswd && \
    echo 'UsePAM no\nPermitTunnel no\nAcceptEnv LANG LC_*' > /etc/ssh/sshd_config


# Compile bastille and cleanup
COPY main.c /opt

# -DDEBUG
RUN gcc -o /bin/bastille main.c -L/usr/include -lreadline && rm -v main.c /tmp/rockyou15.txt
CMD /usr/sbin/sshd -D