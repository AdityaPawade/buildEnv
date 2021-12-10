FROM debian:buster-slim

# Install basic utilities
RUN mkdir /var/run/sshd
RUN apt-get update && \
    apt-get install -y --force-yes adduser vim sudo git wget ftp curl openssh-server wget htop

ENV ADTSW_HOME /home/adtsw
ARG user=adtsw
ARG group=adtsw
ARG uid=9998
ARG gid=9998

RUN groupadd -g ${gid} ${group} \
    && useradd -d "$ADTSW_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN echo adtsw  ALL = NOPASSWD: ALL >> /etc/sudoers
