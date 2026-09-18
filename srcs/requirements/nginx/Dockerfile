FROM alpine:3.23.5

RUN apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/equentin.crt \
    -keyout /etc/nginx/ssl/equentin.key \
    -subj "/C=FR/ST=ARA/L=Lyon/O=42/CN=Ethan Quentin/UID=equentin"

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 443
