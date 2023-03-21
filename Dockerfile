FROM ubuntu:20.04

RUN apt update && \
    apt-get -y install python3 python3-pip build-essential nmap netcat curl wget vim iproute2 ftp iputils-ping && \
    pip install requests && \
    mkdir /flags/ && chmod 777 /flags

WORKDIR /opt

RUN apt-get install -y bc sudo libreadline-dev 
# Build the jail
COPY bastille /bin
COPY main.c /opt
RUN gcc -o /bin/bbash main.c -L/usr/include -lreadline 
RUN chmod +x /bin/bastille && bastille build && useradd user

USER user
CMD bastille