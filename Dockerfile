FROM ubuntu:bionic

ARG NODE_VERSION=v14.15.3
ARG PHP_VERSION=8.0

ENV YARN_CACHE_FOLDER=/var/www/.yarn
ENV NODE_DISTRO=linux-x64
ENV PATH="/usr/local/lib/nodejs/node-$NODE_VERSION-$NODE_DISTRO/bin:$PATH"

RUN set -eux \
    && mkdir -p ${YARN_CACHE_FOLDER} \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        zip \
        wget \
        curl \
        gnupg \
        supervisor \
        software-properties-common \
    && add-apt-repository ppa:nginx/stable && add-apt-repository ppa:ondrej/php && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        php${PHP_VERSION} \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-dev \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-opcache\
        php${PHP_VERSION}-xdebug \
        php${PHP_VERSION}-apcu \
        nginx && \
    usermod -d /var/www www-data && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION} && \
    update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION} && \
    ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm  && \
    ln -s /etc/php/${PHP_VERSION} /etc/php/current  && \
    curl -s https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin && \
    chmod a+x /usr/local/bin/composer && \
    mkdir -p /usr/local/lib/nodejs && \
    wget https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-$NODE_DISTRO.tar.xz && \
    tar -xJf node-$NODE_VERSION-$NODE_DISTRO.tar.xz -C /usr/local/lib/nodejs && \
    rm -rf node-$NODE_VERSION-$NODE_DISTRO.tar.xz && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && apt install --no-install-recommends yarn && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY entrypoint.sh /entrypoint.sh
COPY supervisor/supervisord-default.conf /etc/supervisor/conf.d/supervisord-default.conf
COPY nginx /etc/nginx
COPY php /etc/php/${PHP_VERSION}/fpm

WORKDIR /var/www

RUN rm -rf /var/www/html/* && \
    echo '<?php phpinfo(); ?>' > /var/www/html/index.php && \
    mkdir -p /var/log/nginx /var/lib/nginx/body && \
    chown www-data:www-data -R /var/www /var/log/nginx /var/lib/nginx


ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
