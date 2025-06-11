FROM alpine:3

RUN apk add --no-cache curl nmap openssh yq
COPY ./files/ /

ENV SSH_PORT=2022
ENV USER_PASSWORD=123456

CMD ["/entrypoint.sh"]
