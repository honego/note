# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

# References:
# https://cn.angie.software/angie/docs/installation/sourcebuild
# https://github.com/nginx/docker-nginx

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

FROM base AS dist

LABEL org.opencontainers.image.authors="honeok <i@honeok.com>"

## angie
ARG ANGIE_VERSION=1.12.1
ENV ANGIE_VERSION=$ANGIE_VERSION

## angie modules
# https://cn.angie.software/angie/docs/installation/external-modules

# https://github.com/leev/ngx_http_geoip2_module
ARG NGX_GEOIP2_VERSION=3.4
ENV NGX_GEOIP2_VERSION=$NGX_GEOIP2_VERSION

# https://github.com/openresty/headers-more-nginx-module
ARG HEADERS_MORE_VERSION=0.40
ENV HEADERS_MORE_VERSION=$HEADERS_MORE_VERSION

# https://github.com/facebook/zstd
ARG NGX_ZSTD_VERSION=1.5.7
ENV NGX_ZSTD_VERSION=$NGX_ZSTD_VERSION

## Build arguments.
ARG ANGIE_BUILD_OPTIONS="\
    --user=angie \
    --group=angie \
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
    --without-select_module \
    --without-poll_module \
    --with-threads \
    --with-file-aio \
    --with-pcre \
    --with-pcre-jit \
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
    --with-stream \
    --with-stream_acme_module \
    --with-stream_mqtt_preread_module \
    --with-stream_rdp_preread_module \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    "

ARG ANGIE_BUILD_DEPS="\
    --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs -Wl,-z,relro -Wl,-z,now' \
    "

ARG ANGIE_ADD_BUILD_OPTIONS="\
    --add-module=../ngx_brotli \
    --add-module=../ngx_http_geoip2_module-$NGX_GEOIP2_VERSION \
    --add-module=../headers-more-nginx-module-$HEADERS_MORE_VERSION \
    --add-module=../zstd-nginx-module \
    "

RUN set -ex \
    && addgroup -g 101 -S angie \
    && adduser -S -D -H -u 101 -h /var/cache/angie -s /sbin/nologin -G angie -g angie angie \
    && apk add --no-cache --virtual .build-deps \
        brotli-dev \
        build-base \
        curl \
        git \
        libmaxminddb-dev \
        lz4-dev \
        linux-headers \
        openssl-dev \
        pcre2-dev \
        perl-dev \
        tar \
        xz-dev \
        zlib-dev \
    && apk add --no-cache \
        curl \
        gettext-envsubst \
        tzdata \
    && cd /tmp \
# install third-party modules.
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
    && curl -fsSL https://github.com/leev/ngx_http_geoip2_module/archive/$NGX_GEOIP2_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz | tar fxz - \
    && curl -fsSL https://github.com/facebook/zstd/releases/download/v$NGX_ZSTD_VERSION/zstd-$NGX_ZSTD_VERSION.tar.gz | tar fxz - \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module.git \
# run build.
    && curl -fsSL https://download.angie.software/files/angie-$ANGIE_VERSION.tar.gz | tar fxz - \
    && cd angie-$ANGIE_VERSION \
    && eval ./configure $ANGIE_BUILD_OPTIONS $ANGIE_BUILD_DEPS $ANGIE_ADD_BUILD_OPTIONS \
    && make -j$(nproc) \
    && make -j$(nproc) install \
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
    && mkdir -p \
        /var/cache/angie \
        /usr/share/angie \
        /usr/lib/angie/modules \
    && mv /etc/angie/html /usr/share/angie \
    && ln -sf /usr/lib/angie/modules /etc/angie/modules \
    && ln -sf /usr/sbin/angie /usr/sbin/nginx \
    && rm -rf /etc/angie/*.default \
    && rm -f \
        /etc/angie/koi-utf \
        /etc/angie/koi-win \
        /etc/angie/win-utf \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/angie/access.log \
    && ln -sf /dev/stderr /var/log/angie/error.log \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d \
    && rundeps="$( \
        scanelf --needed --nobanner --format '%n#p' \
            /usr/sbin/angie \
        | tr ',' '\n' \
        | sort -u \
        | sed '/^$/d; s/^/so:/' \
    )" \
    && apk add --no-cache --virtual .rundeps $rundeps \
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
