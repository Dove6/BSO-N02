FROM alpine:3

RUN apk add --no-cache curl nmap openssh xmlstarlet yq
COPY ./files/ /

ENV SSH_PORT=2022
ENV USER_PASSWORD=123456
ENV ROUTEROS_HOST=192.168.3.1
ENV ROUTEROS_USERNAME=admin
ENV ROUTEROS_PASSWORD=password
ENV EMAIL_RECIPIENT=dawidsygocki1234@wp.pl

CMD ["/entrypoint.sh"]
