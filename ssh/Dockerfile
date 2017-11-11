FROM ubuntu:16.04
MAINTAINER Vaggelis Kapartzianis <vkapartzianis@gmail.com>

RUN echo "$LOG_TAG Configure SSH" && \
    cd ~ && \
    apt-get -y update && \
    apt-get install -y openssh-client openssh-server && \
    # ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    # ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f .ssh/id_rsa && \
    cat .ssh/id_rsa.pub >> .ssh/authorized_keys && \
    chmod 0600 .ssh/authorized_keys && \
    /bin/echo -e "Host *\n    AddressFamily inet\n    StrictHostKeyChecking no" >> .ssh/config
