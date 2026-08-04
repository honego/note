# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

# References:
# https://cn.angie.software/angie/docs/installation/sourcebuild
# https://github.com/nginx/docker-nginx
# https://tongsuo.net/docs/features/angie
# https://www.keeptrust.cn/help/zsk/836.html

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

FROM base AS dist

LABEL org.opencontainers.image.authors="honeok <i@honeok.com>"

## angie
ARG ANGIE_VERSION="1.12.1"
ENV ANGIE_VERSION=$ANGIE_VERSION

## angie modules
# https://github.com/leev/ngx_http_geoip2_module
ARG NGX_GEOIP2_VERSION="3.4"
ENV NGX_GEOIP2_VERSION=$NGX_GEOIP2_VERSION

# https://github.com/nginx/njs
ARG NGX_NJS_VERSION="1.0.0"
ENV NGX_NJS_VERSION=$NGX_NJS_VERSION

# https://github.com/facebook/zstd
ARG NGX_ZSTD_VERSION="1.5.7"
ENV NGX_ZSTD_VERSION=$NGX_ZSTD_VERSION

# https://github.com/vision5/ngx_devel_kit
ARG NGX_DEVEL_KIT_VERSION="0.3.4"
ENV NGX_DEVEL_KIT_VERSION=$NGX_DEVEL_KIT_VERSION

## lua
# https://github.com/openresty/luajit2
ARG RESTY_LUAJIT_VERSION="2.1-20260724"
ENV RESTY_LUAJIT_VERSION=$RESTY_LUAJIT_VERSION

# https://github.com/openresty/lua-resty-core
ARG RESTY_LUA_CORE_VERSION="0.1.35rc1"
ENV RESTY_LUA_CORE_VERSION=$RESTY_LUA_CORE_VERSION

# https://github.com/openresty/lua-resty-lrucache
ARG RESTY_LUA_LRUCACHE_VERSION="0.15"
ENV RESTY_LUA_LRUCACHE_VERSION=$RESTY_LUA_LRUCACHE_VERSION

# https://github.com/openresty/lua-nginx-module
ARG RESTY_LUA_VERSION="0.10.32rc3"
ENV RESTY_LUA_VERSION=$RESTY_LUA_VERSION

# https://github.com/openresty/lua-upstream-nginx-module
ARG RESTY_LUA_UPSTREAM_VERSION="0.08"
ENV RESTY_LUA_UPSTREAM_VERSION=$RESTY_LUA_UPSTREAM_VERSION

# https://github.com/openresty/headers-more-nginx-module
ARG RESTY_HEADERS_MORE_VERSION="0.40"
ENV RESTY_HEADERS_MORE_VERSION=$RESTY_HEADERS_MORE_VERSION

# https://github.com/openresty/lua-resty-redis
ARG RESTY_LUA_REDIS_VERSION="0.33"
ENV RESTY_LUA_REDIS_VERSION=$RESTY_LUA_REDIS_VERSION

# https://github.com/openresty/lua-resty-memcached
ARG RESTY_LUA_MEMCACHED_VERSION="0.18"
ENV RESTY_LUA_MEMCACHED_VERSION=$RESTY_LUA_MEMCACHED_VERSION

# https://github.com/openresty/stream-lua-nginx-module
ARG RESTY_LUA_STREAM_VERSION="0.0.20rc2"
ENV RESTY_LUA_STREAM_VERSION=$RESTY_LUA_STREAM_VERSION

# https://github.com/openresty/lua-resty-dns
ARG RESTY_LUA_DNS_VERSION="0.23"
ENV RESTY_LUA_DNS_VERSION=$RESTY_LUA_DNS_VERSION

# https://github.com/openresty/lua-resty-lock
ARG RESTY_LUA_LOCK_VERSION="0.09"
ENV RESTY_LUA_LOCK_VERSION=$RESTY_LUA_LOCK_VERSION

# https://github.com/openresty/lua-resty-balancer
ARG RESTY_LUA_BALANCER_VERSION="0.05"
ENV RESTY_LUA_BALANCER_VERSION=$RESTY_LUA_BALANCER_VERSION

# https://github.com/knyar/nginx-lua-prometheus
ARG RESTY_LUA_PROMETHEUS_VERSION="0.20240525"
ENV RESTY_LUA_PROMETHEUS_VERSION=$RESTY_LUA_PROMETHEUS_VERSION

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
    --with-http_image_filter_module=dynamic \
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
    --with-http_xslt_module=dynamic \
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

ARG ANGIE_ADD_BUILD_OPTIONS="\
    --add-module=../ngx_devel_kit-$NGX_DEVEL_KIT_VERSION \
    "

ARG ANGIE_DYNA_BUILD_OPTIONS="\
    --with-compat \
    --add-dynamic-module=../ngx_brotli \
    --add-dynamic-module=../ngx_http_geoip2_module-$NGX_GEOIP2_VERSION \
    --add-dynamic-module=../njs-$NGX_NJS_VERSION/nginx \
    --add-dynamic-module=../zstd-nginx-module \
    "

ARG ANGIE_BUILD_DEPS="\
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openssl3/include -I/usr/local/pcre2/include' \
    --with-ld-opt='-L/usr/local/openssl3/lib -L/usr/local/pcre2/lib -Wl,-rpath,/usr/local/openssl3/lib:/usr/local/pcre2/lib -Wl,-z,relro -Wl,-z,now' \
    "

ARG ANGIE_LUAJIT_OPTIONS=""

RUN set -ex \
    && addgroup -g 101 -S angie \
    && adduser -S -D -H -u 101 -h /var/cache/angie -s /sbin/nologin -G angie -g angie angie \
    && apk add --no-cache --virtual .build-deps \
        brotli-dev \
        build-base \
        git \
        gd-dev \
        libxml2-dev \
        libxslt-dev \
        libmaxminddb-dev \
        linux-headers \
        lz4-dev \
        quickjs-dev \
        tar \
        xz-dev \
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
        --prefix=/usr/local/openssl3 \
        --libdir=lib \
        -Wl,-rpath,/usr/local/openssl3/lib \
        $ANGIE_OPENSSL_BUILD_OPTIONS \
    && make -j$(nproc) \
    && make -j$(nproc) install_sw \
    && cd /tmp \
    && curl -fsSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$ANGIE_PCRE_VERSION/pcre2-$ANGIE_PCRE_VERSION.tar.gz | tar fxz - \
    && cd pcre2-$ANGIE_PCRE_VERSION \
    && CFLAGS="-g -O3" ./configure \
        --prefix=/usr/local/pcre2 \
        --libdir=/usr/local/pcre2/lib \
        $ANGIE_PCRE_BUILD_OPTIONS \
    && CFLAGS="-g -O3" make -j$(nproc) \
    && CFLAGS="-g -O3" make -j$(nproc) install \
    && cd /tmp \
# install luajit.
    && curl -fsSL https://github.com/openresty/luajit2/archive/v$RESTY_LUAJIT_VERSION.tar.gz | tar fxz - \
    && cd luajit2-$RESTY_LUAJIT_VERSION \
    && make -j$(nproc) TARGET_STRIP=@: CCDEBUG=-g XCFLAGS='-DLUAJIT_ENABLE_LUA52COMPAT' CC=cc PREFIX=/usr/local/luajit \
    && make install TARGET_STRIP=@: CCDEBUG=-g XCFLAGS='-DLUAJIT_ENABLE_LUA52COMPAT' CC=cc PREFIX=/usr/local/luajit \
# install openresty modules.
    && curl -fsSL https://github.com/vision5/ngx_devel_kit/archive/v$NGX_DEVEL_KIT_VERSION.tar.gz | tar fxz - \
# install third-party modules.
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
    && curl -fsSL https://github.com/leev/ngx_http_geoip2_module/archive/$NGX_GEOIP2_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/v$RESTY_HEADERS_MORE_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/nginx/njs/archive/$NGX_NJS_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/facebook/zstd/releases/download/v$NGX_ZSTD_VERSION/zstd-$NGX_ZSTD_VERSION.tar.gz | tar fxz - \
    && cd zstd-$NGX_ZSTD_VERSION \
    && make clean \
    && CFLAGS="-fPIC" make -j$(nproc) \
    && make -j$(nproc) install \
    && cd /tmp \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module.git \
# run build.
    && curl -fsSL https://download.angie.software/files/angie-$ANGIE_VERSION.tar.gz | tar fxz - \
    && cd angie-$ANGIE_VERSION \
    && eval ./configure $ANGIE_BUILD_OPTIONS $ANGIE_DYNA_BUILD_OPTIONS $ANGIE_BUILD_DEPS $ANGIE_LUAJIT_OPTIONS \
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
