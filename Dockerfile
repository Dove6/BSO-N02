FROM alpine:3

RUN apk add --no-cache curl nmap openssh yq
COPY ./files/ /

ENV USER_PASSWORD=123456

ENTRYPOINT /entrypoint.sh
EXPOSE 22/tcp
CMD /usr/sbin/sshd -D

