FROM ubuntu:24.04

RUN apt-get update && apt-get install -y openssh-server sudo && \
    usermod -aG sudo ubuntu && \
    mkdir -p /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && \
    echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ubuntu && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config && \
    mkdir -p /run/sshd && chmod 0755 /run/sshd

COPY ./id_rsa.pub /home/ubuntu/.ssh/authorized_keys

RUN chmod 600 /home/ubuntu/.ssh/authorized_keys && \
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh

EXPOSE 22 80

CMD ["/usr/sbin/sshd", "-D"]
