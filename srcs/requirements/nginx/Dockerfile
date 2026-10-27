FROM alpine:3.23.7

RUN apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/equentin.crt \
    -keyout /etc/nginx/ssl/equentin.key \
    -subj "/C=FR/ST=ARA/L=Lyon/O=42/CN=equentin.42.fr/UID=equentin" \
    -days 365 \
    -addext "subjectAltName=DNS:equentin.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 443
