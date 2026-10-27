FROM alpine:3.23.7

RUN apk add --no-cache php84 php84-fpm php84-mysqli php84-phar php84-iconv php84-curl php84-mbstring mariadb-client

RUN mkdir -p /var/www
RUN wget https://fr.wordpress.org/wordpress-7.1-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-7.1-fr_FR.tar.gz && rm wordpress-7.1-fr_FR.tar.gz

RUN adduser -u 82 -D -S -G www-data www-data 2>/dev/null

RUN wget https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar
RUN chmod +x wp-cli-2.12.0.phar
RUN mv wp-cli-2.12.0.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php84/php-fpm.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

WORKDIR /var/www/wordpress

ENTRYPOINT [ "/entrypoint.sh" ]
