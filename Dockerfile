FROM alpine:3

RUN apk add --no-cache curl nmap openssh yq
COPY ./files/ /

ARG SSH_PORT=2022
ENV SSH_PORT=${SSH_PORT}
ENV USER_PASSWORD=123456

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE ${SSH_PORT}/tcp
CMD ["/usr/sbin/sshd", "-D", "-p ${SSH_PORT}"]
