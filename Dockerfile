FROM alpine:3.12

RUN apk add --no-cache \
      iptables \
      ip6tables \
      ipset \
      iproute2 \
      ipvsadm \
      conntrack-tools \
      curl \
      bash && \
    mkdir -p /var/lib/gobgp && \
    mkdir -p /usr/local/share/bash-completion && \
    curl -L -o /usr/local/share/bash-completion/bash-completion \
        https://raw.githubusercontent.com/scop/bash-completion/master/bash_completion

COPY build/image-assets/bashrc /root/.bashrc
COPY build/image-assets/profile /root/.profile
COPY build/image-assets/vimrc /root/.vimrc
COPY build/image-assets/motd-kube-router.sh /etc/motd-kube-router.sh
COPY kube-router gobgp /usr/local/bin/

# Use iptables-wrappers so that correct version of iptables-legacy or iptables-nft gets used. Alpine contains both, but
# which version is used should be based on the host system as well as where rules that may have been added before
# kube-router are being placed. For more information see: https://github.com/kubernetes-sigs/iptables-wrappers
COPY build/image-assets/iptables-wrapper-installer.sh /
RUN /iptables-wrapper-installer.sh


# Since alpine image doesn't contain /etc/nsswitch.conf, the hosts in /etc/hosts (e.g. localhost)
# cannot be used. So manually add /etc/nsswitch.conf to work around this issue.
RUN echo "hosts: files dns" > /etc/nsswitch.conf

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/kube-router"]
