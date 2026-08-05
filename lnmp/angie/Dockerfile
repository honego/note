# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

# References:
# https://cn.angie.software/angie/docs/installation/sourcebuild
# https://github.com/nginx/docker-nginx
# https://github.com/fabiocicerchia/nginx-lua

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

FROM base AS deps

## angie
ARG ANGIE_VERSION="1.12.1"
ENV ANGIE_VERSION=$ANGIE_VERSION

## angie modules
# https://github.com/leev/ngx_http_geoip2_module
ARG NGX_GEOIP2_VERSION="3.4"
ENV NGX_GEOIP2_VERSION=$NGX_GEOIP2_VERSION

# https://github.com/facebook/zstd
ARG NGX_ZSTD_VERSION="1.5.7"
ENV NGX_ZSTD_VERSION=$NGX_ZSTD_VERSION

ARG ANGIE_OPENSSL_VERSION="3.5.7"
ARG ANGIE_OPENSSL_PATCH_VERSION="3.5.5"
ARG ANGIE_OPENSSL_URL_BASE="https://github.com/openssl/openssl/releases/download/openssl-$ANGIE_OPENSSL_VERSION"

ARG ANGIE_PCRE_VERSION="10.47"

ARG ANGIE_DYNA_BUILD_OPTIONS="\
    --with-stream \
    --with-compat \
    --add-dynamic-module=../ngx_brotli \
    --add-dynamic-module=../ngx_http_geoip2_module-$NGX_GEOIP2_VERSION \
    --add-dynamic-module=../zstd-nginx-module \
    "

RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps \
        brotli-dev \
        build-base \
        curl \
        git \
        libmaxminddb-dev \
        lz4-dev \
        tar \
        xz-dev \
        zlib-dev \
    && cd /tmp \
    && curl -fsSL $ANGIE_OPENSSL_URL_BASE/openssl-$ANGIE_OPENSSL_VERSION.tar.gz | tar fxz - \
    && cd openssl-$ANGIE_OPENSSL_VERSION \
    && curl -fsSL https://github.com/openresty/openresty/raw/master/patches/openssl-$ANGIE_OPENSSL_PATCH_VERSION-sess_set_get_cb_yield.patch | patch -p1 \
    && cd /tmp \
    && curl -fsSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$ANGIE_PCRE_VERSION/pcre2-$ANGIE_PCRE_VERSION.tar.gz | tar fxz - \
# install third-party modules.
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
    && curl -fsSL https://github.com/leev/ngx_http_geoip2_module/archive/$NGX_GEOIP2_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/facebook/zstd/releases/download/v$NGX_ZSTD_VERSION/zstd-$NGX_ZSTD_VERSION.tar.gz | tar fxz - \
    && cd zstd-$NGX_ZSTD_VERSION \
    && make clean \
    && CFLAGS="-fPIC" make -j$(nproc) \
    && make -j$(nproc) install \
    && cd /tmp \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module.git \
    && curl -fsSL https://download.angie.software/files/angie-$ANGIE_VERSION.tar.gz | tar fxz - \
    && cd angie-$ANGIE_VERSION \
    && eval ./configure \
        --with-pcre=../pcre2-$ANGIE_PCRE_VERSION \
        --with-pcre-jit \
        --with-openssl=../openssl-$ANGIE_OPENSSL_VERSION \
        $ANGIE_DYNA_BUILD_OPTIONS \
    && make \
    && strip objs/*.so \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*

FROM base AS dist

LABEL org.opencontainers.image.authors="honeok <i@honeok.com>"

## angie
ARG ANGIE_VERSION="1.12.1"
ENV ANGIE_VERSION=$ANGIE_VERSION

# copy dynamic modules.
COPY --from=deps /tmp/angie-$ANGIE_VERSION/objs/*.so /usr/lib/angie/modules/

# https://github.com/openresty/ngx_devel_kit
ARG NGX_DEVEL_KIT_VERSION="0.3.5"
ENV NGX_DEVEL_KIT_VERSION=$NGX_DEVEL_KIT_VERSION

## lua
# https://github.com/openresty/luajit2
ARG RESTY_LUAJIT_VERSION="2.1-20260724"
ENV RESTY_LUAJIT_VERSION=$RESTY_LUAJIT_VERSION

ARG LUAJIT_LIB="/usr/local/angie/luajit/lib"
ENV LUAJIT_LIB=$LUAJIT_LIB
ARG LUAJIT_INC="/usr/local/angie/luajit/include/luajit-2.1"
ENV LUAJIT_INC=$LUAJIT_INC

ARG RESTY_LUALIB_PATH="/usr/local/angie/lualib"

# https://github.com/openresty/lua-resty-core
ARG RESTY_LUA_CORE_VERSION="0.1.35rc1"
ENV RESTY_LUA_CORE_VERSION=$RESTY_LUA_CORE_VERSION

# https://github.com/openresty/lua-resty-lrucache
ARG RESTY_LUA_LRUCACHE_VERSION="0.15"
ENV RESTY_LUA_LRUCACHE_VERSION=$RESTY_LUA_LRUCACHE_VERSION

# https://github.com/openresty/lua-resty-redis
ARG RESTY_LUA_REDIS_VERSION="0.33"
ENV RESTY_LUA_REDIS_VERSION=$RESTY_LUA_REDIS_VERSION

# https://github.com/openresty/lua-resty-memcached
ARG RESTY_LUA_MEMCACHED_VERSION="0.18"
ENV RESTY_LUA_MEMCACHED_VERSION=$RESTY_LUA_MEMCACHED_VERSION

# https://github.com/openresty/lua-resty-dns
ARG RESTY_LUA_DNS_VERSION="0.23"
ENV RESTY_LUA_DNS_VERSION=$RESTY_LUA_DNS_VERSION

# https://github.com/openresty/lua-resty-lock
ARG RESTY_LUA_LOCK_VERSION="0.09"
ENV RESTY_LUA_LOCK_VERSION=$RESTY_LUA_LOCK_VERSION

# https://github.com/openresty/lua-resty-balancer
ARG RESTY_LUA_BALANCER_VERSION="0.05"
ENV RESTY_LUA_BALANCER_VERSION=$RESTY_LUA_BALANCER_VERSION

# https://github.com/openresty/set-misc-nginx-module
ARG RESTY_SET_MISC_VERSION="0.34"
ENV RESTY_SET_MISC_VERSION=$RESTY_SET_MISC_VERSION

# https://github.com/openresty/lua-nginx-module
ARG RESTY_LUA_VERSION="0.10.32rc3"
ENV RESTY_LUA_VERSION=$RESTY_LUA_VERSION

# https://github.com/openresty/lua-upstream-nginx-module
ARG RESTY_LUA_UPSTREAM_VERSION="0.08"
ENV RESTY_LUA_UPSTREAM_VERSION=$RESTY_LUA_UPSTREAM_VERSION

# https://github.com/openresty/headers-more-nginx-module
ARG RESTY_HEADERS_MORE_VERSION="0.40"
ENV RESTY_HEADERS_MORE_VERSION=$RESTY_HEADERS_MORE_VERSION

# https://github.com/openresty/stream-lua-nginx-module
ARG RESTY_LUA_STREAM_VERSION="0.0.20rc2"
ENV RESTY_LUA_STREAM_VERSION=$RESTY_LUA_STREAM_VERSION

## Build arguments.
# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-openssl3/APKBUILD
ARG ANGIE_OPENSSL_VERSION="3.5.7"
ARG ANGIE_OPENSSL_PATCH_VERSION="3.5.5"
ARG ANGIE_OPENSSL_URL_BASE="https://github.com/openssl/openssl/releases/download/openssl-$ANGIE_OPENSSL_VERSION"
ARG ANGIE_OPENSSL_BUILD_OPTIONS="enable-camellia enable-cms enable-fips enable-ktls enable-md2 \
    enable-rc5 enable-rfc3779 enable-seed enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers \
    "

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-pcre2/APKBUILD
ARG ANGIE_PCRE_VERSION="10.47"
ARG ANGIE_PCRE_BUILD_OPTIONS="--enable-jit --enable-pcre2grep-jit --disable-bsr-anycrlf --disable-coverage --disable-ebcdic --disable-fuzz-support \
    --disable-jit-sealloc --disable-never-backslash-C --enable-newline-is-lf --enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32 \
    --enable-pcre2grep-callout --enable-pcre2grep-callout-fork --disable-pcre2grep-libbz2 --disable-pcre2grep-libz --disable-pcre2test-libedit \
    --enable-percent-zt --disable-rebuild-chartables --enable-shared --disable-static --disable-silent-rules --enable-unicode --disable-valgrind \
    "

ARG ANGIE_BUILD_OPTIONS="\
# General
    --user=angie \
    --group=angie \
# Paths
    --prefix=/etc/angie \
    --sbin-path=/usr/sbin/angie \
    --modules-path=/usr/lib/angie/modules \
    --conf-path=/etc/angie/angie.conf \
    --error-log-path=/var/log/angie/error.log \
    --pid-path=/run/angie.pid \
    --lock-path=/run/angie.lock \
    --http-acme-client-path=/var/lib/angie/acme \
    --http-log-path=/var/log/angie/access.log \
    --http-client-body-temp-path=/var/cache/angie/client_temp \
    --http-proxy-temp-path=/var/cache/angie/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/angie/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/angie/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/angie/scgi_temp \
# Features and dependencies
    --without-select_module \
    --without-poll_module \
    --with-threads \
    --with-file-aio \
    --with-pcre \
    --with-pcre-jit \
# HTTP
    --with-http_acme_module \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
# Stream modules
    --with-stream \
    --with-stream_acme_module \
    --with-stream_mqtt_preread_module \
    --with-stream_rdp_preread_module \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
# Mail
    --with-mail \
    --with-mail_ssl_module \
    --without-mail_imap_module \
    --without-mail_pop3_module \
    --without-mail_smtp_module \
    "

ARG ANGIE_BUILD_DEPS="\
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/angie/openssl3/include -I/usr/local/angie/pcre2/include' \
    --with-ld-opt='-L/usr/local/angie/openssl3/lib -L/usr/local/angie/pcre2/lib -Wl,-rpath,/usr/local/angie/luajit/lib:/usr/local/angie/openssl3/lib:/usr/local/angie/pcre2/lib -Wl,-z,relro -Wl,-z,now' \
    "

ARG ANGIE_ADD_BUILD_OPTIONS="\
    --add-module=../ngx_devel_kit-$NGX_DEVEL_KIT_VERSION \
    --add-module=../set-misc-nginx-module-$RESTY_SET_MISC_VERSION \
    --add-module=../lua-nginx-module-$RESTY_LUA_VERSION \
    --add-module=../lua-upstream-nginx-module-$RESTY_LUA_UPSTREAM_VERSION \
    --add-module=../headers-more-nginx-module-$RESTY_HEADERS_MORE_VERSION \
    --add-module=../stream-lua-nginx-module-$RESTY_LUA_STREAM_VERSION \
    "

RUN set -ex \
    && addgroup -g 101 -S angie \
    && adduser -S -D -H -u 101 -h /var/cache/angie -s /sbin/nologin -G angie -g angie angie \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        linux-headers \
        perl-dev \
        tar \
        zlib-dev \
    && apk add --no-cache \
        curl \
# Add `envsubst` for templating environment variables
        gettext-envsubst \
        tzdata \
    && cd /tmp \
    && curl -fsSL $ANGIE_OPENSSL_URL_BASE/openssl-$ANGIE_OPENSSL_VERSION.tar.gz | tar fxz - \
    && cd openssl-$ANGIE_OPENSSL_VERSION \
    && curl -fsSL https://github.com/openresty/openresty/raw/master/patches/openssl-$ANGIE_OPENSSL_PATCH_VERSION-sess_set_get_cb_yield.patch | patch -p1 \
    && eval ./config shared zlib \
        --prefix=/usr/local/angie/openssl3 \
        --libdir=lib \
        -Wl,-rpath,/usr/local/angie/openssl3/lib \
        $ANGIE_OPENSSL_BUILD_OPTIONS \
    && make -j$(nproc) \
    && make -j$(nproc) install_sw \
    && cd /tmp \
    && curl -fsSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$ANGIE_PCRE_VERSION/pcre2-$ANGIE_PCRE_VERSION.tar.gz | tar fxz - \
    && cd pcre2-$ANGIE_PCRE_VERSION \
    && CFLAGS="-g -O3" ./configure \
        --prefix=/usr/local/angie/pcre2 \
        --libdir=/usr/local/angie/pcre2/lib \
        $ANGIE_PCRE_BUILD_OPTIONS \
    && CFLAGS="-g -O3" make -j$(nproc) \
    && CFLAGS="-g -O3" make -j$(nproc) install \
    && cd /tmp \
# install luajit and lualib.
    && curl -fsSL https://github.com/openresty/luajit2/archive/v$RESTY_LUAJIT_VERSION.tar.gz | tar fxz - \
    && cd luajit2-$RESTY_LUAJIT_VERSION \
    && make -j$(nproc) TARGET_STRIP=@: CCDEBUG=-g XCFLAGS='-DLUAJIT_ENABLE_LUA52COMPAT' CC=cc PREFIX=/usr/local/angie/luajit \
    && make install TARGET_STRIP=@: CCDEBUG=-g XCFLAGS='-DLUAJIT_ENABLE_LUA52COMPAT' CC=cc PREFIX=/usr/local/angie/luajit \
    && cd /tmp \
    && curl -fsSL https://github.com/openresty/lua-resty-core/archive/v$RESTY_LUA_CORE_VERSION.tar.gz | tar fxz - \
    && cd lua-resty-core-$RESTY_LUA_CORE_VERSION \
    && make install LUA_LIB_DIR=$RESTY_LUALIB_PATH \
    && cd /tmp \
    && curl -fsSL https://github.com/openresty/lua-resty-lrucache/archive/v$RESTY_LUA_LRUCACHE_VERSION.tar.gz | tar fxz - \
    && cd lua-resty-lrucache-$RESTY_LUA_LRUCACHE_VERSION \
    && make install LUA_LIB_DIR=$RESTY_LUALIB_PATH \
    && cd /tmp \
    && curl -fsSL https://github.com/openresty/lua-resty-redis/archive/v$RESTY_LUA_REDIS_VERSION.tar.gz | tar fxz - \
    && cd lua-resty-redis-$RESTY_LUA_REDIS_VERSION \
    && make install LUA_LIB_DIR=$RESTY_LUALIB_PATH \
    && cd /tmp \
    && curl -fsSL https://github.com/openresty/lua-resty-memcached/archive/v$RESTY_LUA_MEMCACHED_VERSION.tar.gz | tar fxz - \
    && cd lua-resty-memcached-$RESTY_LUA_MEMCACHED_VERSION \
    && make install LUA_LIB_DIR=$RESTY_LUALIB_PATH \
    && cd /tmp \
    && curl -fsSL https://github.com/openresty/lua-resty-dns/archive/v$RESTY_LUA_DNS_VERSION.tar.gz | tar fxz - \
    && cd lua-resty-dns-$RESTY_LUA_DNS_VERSION \
    && make install LUA_LIB_DIR=$RESTY_LUALIB_PATH \
    && cd /tmp \
    && curl -fsSL https://github.com/openresty/lua-resty-lock/archive/v$RESTY_LUA_LOCK_VERSION.tar.gz | tar fxz - \
    && cd lua-resty-lock-$RESTY_LUA_LOCK_VERSION \
    && make install LUA_LIB_DIR=$RESTY_LUALIB_PATH \
    && cd /tmp \
    && curl -fsSL https://github.com/openresty/lua-resty-balancer/archive/v$RESTY_LUA_BALANCER_VERSION.tar.gz | tar fxz - \
    && cd lua-resty-balancer-$RESTY_LUA_BALANCER_VERSION \
    && make -j$(nproc) \
    && make install LUA_LIB_DIR=$RESTY_LUALIB_PATH \
    && cd /tmp \
# install openresty modules.
    && curl -fsSL https://github.com/openresty/ngx_devel_kit/archive/v$NGX_DEVEL_KIT_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/set-misc-nginx-module/archive/v$RESTY_SET_MISC_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/lua-nginx-module/archive/v$RESTY_LUA_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/lua-upstream-nginx-module/archive/v$RESTY_LUA_UPSTREAM_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/v$RESTY_HEADERS_MORE_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/stream-lua-nginx-module/archive/v$RESTY_LUA_STREAM_VERSION.tar.gz | tar fxz - \
# run build.
    && curl -fsSL https://download.angie.software/files/angie-$ANGIE_VERSION.tar.gz | tar fxz - \
    && cd angie-$ANGIE_VERSION \
    && eval ./configure $ANGIE_BUILD_OPTIONS $ANGIE_BUILD_DEPS $ANGIE_ADD_BUILD_OPTIONS \
    && make -j$(nproc) \
    && make -j$(nproc) install \
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
    && mkdir -p /var/cache/angie /usr/share/angie \
    && mv /etc/angie/html /usr/share/angie \
    && ln -sf /usr/sbin/angie /usr/sbin/nginx \
    && ln -sf /usr/lib/angie/modules /etc/angie/modules \
    && rm -f /etc/angie/*.default /etc/angie/koi-utf /etc/angie/koi-win /etc/angie/win-utf \
    && chown -R angie:angie /var/cache/angie /var/log/angie \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/angie/access.log \
    && ln -sf /dev/stderr /var/log/angie/error.log \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/* /tmp/*

# Add additional binaries into PATH for convenience.
ENV PATH=$PATH:/usr/local/angie/luajit/bin

# Copy nginx configuration files.
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine
COPY angie.conf /etc/angie/angie.conf
COPY angie.vh.default.conf /etc/angie/conf.d/default.conf

# https://github.com/nginx/docker-nginx/tree/master/entrypoint
COPY --chmod=755 docker-entrypoint.sh /
COPY --chmod=755 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY --chmod=755 15-local-resolvers.envsh /docker-entrypoint.d
COPY --chmod=755 20-envsubst-on-templates.sh /docker-entrypoint.d
COPY --chmod=755 30-tune-worker-processes.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

# https://github.com/ammnt/angie
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD ["angie", "-qt"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests.
# See https://github.com/nginx/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

CMD ["angie", "-g", "daemon off;"]
