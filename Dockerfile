FROM teddysun/trojan-go:0.10.6

EXPOSE 443 80

RUN apk update && apk add --no-cache caddy

COPY ./index.html /opt/trojan/wwwroot/

COPY ./entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ ]