FROM debian:buster-20230904 AS base

ENTRYPOINT ["/usr/local/bin/docker-unit.sh"]
CMD ["/usr/lib/unit/sbin/unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock", "--pid", "/var/run/unit.pid", "--log", "/var/log/unit.log", "--modules", "/usr/lib/unit/modules", "--state", "/usr/lib/unit/state/", "--tmp", "/var/tmp/"]
WORKDIR "/www"
EXPOSE  "2001" "2002"
STOPSIGNAL SIGTERM

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn
ENV DEBIAN_FRONTEND noninteractive

ENV PHP_VERSION         8.2
ENV UNIT_GIT_VERSION    1.29.0
ARG BUILDPLATFORM

RUN apt-get update \
    && apt-get install -y --no-install-recommends lsb-release ca-certificates curl gnupg gnupg2 gnupg1 wget\
    && wget -qO - https://packages.confluent.io/deb/7.3/archive.key | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] https://packages.confluent.io/deb/7.3 stable main" > /etc/apt/sources.list.d/php.list' \
    && sh -c 'echo "deb https://packages.confluent.io/clients/deb $(lsb_release -cs) main" >> /etc/apt/sources.list.d/php.list' \
    && curl -s --output /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
    && ln -s /bin/sed /usr/bin/sed \
    && apt-get update \
    && apt-get install -y -q --no-install-recommends \
                    git \
                    vim \
                    nano \
                    less \
                    mc \
                    zip \
                    unzip \
                    gcc \
                    build-essential \
                    librdkafka-dev \
                    php-pear \
                    php${PHP_VERSION} \
                    php${PHP_VERSION}-dev \
                    php${PHP_VERSION}-cli \
                    php${PHP_VERSION}-curl \
                    php${PHP_VERSION}-mysql \
                    php${PHP_VERSION}-mysqli \
                    php${PHP_VERSION}-fpm \
                    php${PHP_VERSION}-embed \
                    php${PHP_VERSION}-cgi \
                    php${PHP_VERSION}-common \
                    php${PHP_VERSION}-mbstring \
                    php${PHP_VERSION}-bcmath \
                    php${PHP_VERSION}-xml \
                    php${PHP_VERSION}-intl \
                    php${PHP_VERSION}-gd \
                    php${PHP_VERSION}-gmp \
                    php${PHP_VERSION}-msgpack \
                    php${PHP_VERSION}-amqp \
    && ln -sf /dev/stdout /var/log/unit.log \
    && cd /opt \
      && wget -O unit.tar.gz https://github.com/nginx/unit/archive/${UNIT_GIT_VERSION}.tar.gz \
        && tar -C ./ -xvf unit.tar.gz --strip-components 1  \
        && ./configure --modules=modules \
        && ./configure php --module=php  \
        && DESTDIR=/usr/lib/unit/  make \
        && DESTDIR=/usr/lib/unit/ make install \
    && rm -Rf /opt/* \
    ;

RUN if [ "$BUILDPLATFORM" != "linux/arm64" ] ; then \
         echo "linux/x86_64!" \
             && apt-get purge -y \
                 libmpx2 \
                 libquadmath0 \
             ; \
     else \
         echo "linux/arm64!" \
             && apt-get purge -y \
                 libmpx2-amd64-cross \
                 libquadmath0-amd64-cross \
             ; \
     fi

RUN apt-get purge -y \
                    autoconf \
                    automake \
                    autopoint \
                    autotools-dev \
                    bsdmainutils \
                    build-essential \
                    cpp debhelper \
                    dh-autoreconf \
                    dh-strip-nondeterminism \
                    dpkg-dev \
                    fakeroot \
                    g++ \
                    g++-7 \
                    gcc \
                    gettext \
                    gettext-base \
                    groff-base \
                    intltool-debian \
                    libalgorithm-diff-perl \
                    libalgorithm-diff-xs-perl \
                    libalgorithm-merge-perl \
                    libarchive-zip-perl \
                    libatomic1 \
                    libc6-dev \
                    libcc1-0 \
                    libc-dev-bin \
                    libcroco3 \
                    libdpkg-perl \
                    libfakeroot \
                    libfile-fcntllock-perl \
                    libfile-stripnondeterminism-perl \
                    libgomp1 \
                    libitm1 \
                    liblocale-gettext-perl \
                    liblsan0 \
                    libltdl-dev \
                    libmail-sendmail-perl \
                    libmpc3 \
                    libpcre2-16-0 \
                    libpcre2-32-0 \
                    libpcre2-dev \
                    libpipeline1 \
                    libsigsegv2 \
                    libssl-dev \
                    libsys-hostname-long-perl \
                    libtimedate-perl \
                    libtool libtsan0 \
                    libubsan0 \
                    linux-libc-dev \
                    m4 make \
                    man-db \
                    manpages \
                    manpages-dev \
                    netbase \
                    patch perl \
                    php-dev \
                    php-pear \
                    pkg-php-tools \
                    po-debconf \
                    shtool \
                    binutils \
                    binutils-x86-64-linux-gnu \
                    binutils-common \
                    cpp-7 gcc-7 \
                    gcc-7-base \
                    libarchive-cpio-perl \
                    libasan4 \
                    libbinutils \
                    libgcc-7-dev \
                    libgdbm-compat4 \
                    libisl19 \
                    libmpfr6 \
                    libstdc++-7-dev \
    ;
RUN apt-get install -y git procps \
    && apt autoremove -y \
    && apt clean -y \
    && apt autoclean -y \
    && apt purge -y --auto-remove


# Add composer
ENV COMPOSER_ALLOW_SUPERUSER    1
ENV COMPOSER_VERSION            2.0.14

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && php /tmp/composer-setup.php --no-ansi --version="${COMPOSER_VERSION}" --install-dir=/usr/local/bin --filename=composer \
    && composer -V \

RUN mkdir -p /usr/local/bin/
COPY docker/docker-unit.sh ./docker/docker-hooks.sh /usr/local/bin/
COPY docker/docker-entrypoint.sh docker/docker-unit-config.json /docker-entrypoint.d/
COPY yii ./

ADD --chown=nobody:nogroup  web ./web
ADD --chown=nobody:nogroup  composer.json ./composer.json
ADD --chown=nobody:nogroup  composer.lock ./composer.lock

RUN /usr/local/bin/composer install --prefer-dist --no-dev

FROM base AS console
#COPY cron /etc/cron.d/sample
CMD php yii ${CONSOLE} *${HOSTNAME}

FROM base AS xdebug
RUN apt-get update \
    && apt-get install php${PHP_VERSION}-xdebug \
    && echo "xdebug.mode = debug"     >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.start_with_request = yes"          >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.idekey= PHPSTORM"          >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.discover_client_host = no"          >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal"          >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.client_port = 9303"                >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.var_display_max_depth = -1"        >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.var_display_max_children = -1"     >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.var_display_max_data = -1"         >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.start_with_request = yes"           >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.max_nesting_level = 500"           >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
    #&& echo "xdebug.remote_client = 127.0.0.1"         >> /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini

