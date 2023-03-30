FROM teddysun/trojan-go:0.10.6

EXPOSE 443 80

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && apk add --no-cache caddy

COPY ./index.html /opt/trojan/wwwroot

COPY ./entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ ]