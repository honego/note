# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2025-2026 honeok <i@honeok.com>
#
# References:
# https://github.com/openresty/docker-openresty
# https://github.com/nginx/docker-nginx

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

FROM base AS dist

LABEL org.opencontainers.image.authors="honeok <i@honeok.com>"

# openresty version.
ARG RESTY_VERSION=1.31.1.1

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-zlib/APKBUILD
ARG RESTY_ZLIB_VERSION=1.3.2

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-openssl3/APKBUILD
ARG RESTY_OPENSSL_VERSION=3.5.7
ARG RESTY_OPENSSL_PATCH_VERSION=3.5.5
ARG RESTY_OPENSSL_BUILD_OPTIONS="\
    enable-camellia enable-cms enable-fips enable-ktls enable-md2 enable-rc5 enable-rfc3779 enable-seed enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers \
    "

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty-pcre2/APKBUILD
ARG RESTY_PCRE_VERSION="10.47"
ARG RESTY_PCRE_BUILD_OPTIONS="\
    --disable-bsr-anycrlf --disable-coverage --disable-ebcdic --disable-fuzz-support --disable-jit-sealloc --disable-never-backslash-C --disable-pcre2grep-libbz2 --disable-pcre2grep-libz \
    --disable-pcre2test-libedit --disable-rebuild-chartables --disable-silent-rules --disable-static --disable-valgrind --enable-jit --enable-newline-is-lf --enable-pcre2-8 --enable-pcre2-16 \
    --enable-pcre2-32 --enable-pcre2grep-callout --enable-pcre2grep-callout-fork --enable-pcre2grep-jit --enable-percent-zt --enable-shared --enable-unicode \
    "

# https://github.com/openresty/openresty-packaging/blob/master/alpine/openresty/APKBUILD
ARG RESTY_CONFIG_OPTIONS="\
    `# options directly inherited from nginx.` \
    --prefix=/usr/local/openresty \
    --sbin-path=/usr/sbin/openresty \
    --modules-path=/usr/lib/openresty/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/openresty/error.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --user=nginx \
    --group=nginx \
    --without-select_module \
    --without-poll_module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --http-log-path=/var/log/openresty/access.log \
    --http-client-body-temp-path=/var/cache/openresty/client_temp \
    --http-proxy-temp-path=/var/cache/openresty/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/openresty/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/openresty/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/openresty/scgi_temp \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    `# openresty specific options.` \
    --without-http_rds_json_module \
    --without-http_rds_csv_module \
    --without-lua_rds_parser \
    "

ARG RESTY_LUAJIT_OPTIONS="\
    --with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT' \
    "

ARG RESTY_PCRE_OPTIONS="\
    --with-pcre-jit \
    "

# These are not intended to be user-specified
ARG RESTY_CONFIG_DEPS="\
    --with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC \
        -I/usr/local/openresty/zlib/include \
        -I/usr/local/openresty/openssl3/include \
        -I/usr/local/openresty/pcre2/include' \
    --with-ld-opt='-L/usr/local/openresty/zlib/lib \
        -L/usr/local/openresty/openssl3/lib \
        -L/usr/local/openresty/pcre2/lib \
        -Wl,-rpath,/usr/local/openresty/zlib/lib:/usr/local/openresty/openssl3/lib:/usr/local/openresty/pcre2/lib' \
    "

ARG RESTY_STRIP_BINARIES=

RUN set -ex \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/openresty -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        bash \
        build-base \
        linux-headers \
        perl-dev \
        tar \
    && apk add --no-cache \
        curl \
        gettext-envsubst \
        tzdata \
##############################
# Build zlib.
    && cd /tmp \
    && curl -fsSL https://github.com/madler/zlib/releases/download/v$RESTY_ZLIB_VERSION/zlib-$RESTY_ZLIB_VERSION.tar.gz | tar fxz - \
    && cd zlib-$RESTY_ZLIB_VERSION \
    && ./configure \
        --prefix=/usr/local/openresty/zlib \
    && make -j$(getconf _NPROCESSORS_ONLN) \
        CFLAGS='-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g3' \
        SFLAGS='-O3 -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g3' \
    && make install \
##############################
# Build openssl.
    && cd /tmp \
    && curl -fsSL https://github.com/openssl/openssl/releases/download/openssl-$RESTY_OPENSSL_VERSION/openssl-$RESTY_OPENSSL_VERSION.tar.gz | tar fxz - \
    && cd openssl-$RESTY_OPENSSL_VERSION \
    && curl -fsSL https://github.com/openresty/openresty/raw/master/patches/openssl-$RESTY_OPENSSL_PATCH_VERSION-sess_set_get_cb_yield.patch | patch -p1 \
    && ./config \
        shared zlib -g \
        --prefix=/usr/local/openresty/openssl3 \
        --libdir=lib \
        -I/usr/local/openresty/zlib/include \
        -L/usr/local/openresty/zlib/lib \
        -Wl,-rpath,/usr/local/openresty/zlib/lib:/usr/local/openresty/openssl3/lib \
        $RESTY_OPENSSL_BUILD_OPTIONS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install_sw \
##############################
# Build pcre2.
    && cd /tmp \
    && curl -fsSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$RESTY_PCRE_VERSION/pcre2-$RESTY_PCRE_VERSION.tar.gz | tar fxz - \
    && cd pcre2-$RESTY_PCRE_VERSION \
    && CFLAGS="-g -O3" ./configure \
        --prefix=/usr/local/openresty/pcre2 \
        --libdir=/usr/local/openresty/pcre2/lib \
        $RESTY_PCRE_BUILD_OPTIONS \
    && CFLAGS="-g -O3" make -j$(getconf _NPROCESSORS_ONLN) \
    && CFLAGS="-g -O3" make install \
##############################
# Build openresty.
    && cd /tmp \
    && curl -fsSL https://openresty.org/download/openresty-$RESTY_VERSION.tar.gz | tar fxz - \
    && cd openresty-$RESTY_VERSION \
    && eval ./configure -j$(getconf _NPROCESSORS_ONLN) $RESTY_CONFIG_OPTIONS $RESTY_LUAJIT_OPTIONS $RESTY_PCRE_OPTIONS $RESTY_CONFIG_DEPS \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
##############################
# https://github.com/nginx/pkg-oss/blob/master/alpine/alpine/APKBUILD-base.in
    && mkdir -p \
        /var/cache/openresty \
        /usr/share/openresty \
        /usr/lib/openresty/modules \
    && mv \
        /usr/local/openresty/nginx/html \
        /usr/share/openresty/html \
    && ln -sf /usr/lib/openresty/modules /etc/nginx/modules \
    && ln -sf /usr/sbin/openresty /usr/sbin/nginx \
    && rm -rf /etc/nginx/*.default \
    && rm -f \
        /etc/nginx/koi-utf \
        /etc/nginx/koi-win \
        /etc/nginx/win-utf \
##############################
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/openresty/access.log \
    && ln -sf /dev/stderr /var/log/openresty/error.log \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d \
    && if [ -n "$RESTY_STRIP_BINARIES" ]; then \
        rm -rf \
            /usr/local/openresty/zlib/include \
            /usr/local/openresty/zlib/lib/*.a \
            /usr/local/openresty/zlib/lib/*.la \
            /usr/local/openresty/zlib/share \
            /usr/local/openresty/openssl3/bin/c_rehash \
            /usr/local/openresty/openssl3/include \
            /usr/local/openresty/openssl3/lib/*.a \
            /usr/local/openresty/openssl3/lib/*.la \
            /usr/local/openresty/pcre2/bin \
            /usr/local/openresty/pcre2/include \
            /usr/local/openresty/pcre2/lib/*.a \
            /usr/local/openresty/pcre2/lib/*.la \
            /usr/local/openresty/pcre2/share \
            /usr/local/openresty/luajit/lib/*.a \
            /usr/local/openresty/luajit/share/man \
        && strip --strip-unneeded /usr/sbin/openresty \
        && find \
            /usr/local/openresty/zlib/lib \
            /usr/local/openresty/openssl3/lib \
            /usr/local/openresty/pcre2/lib \
            /usr/local/openresty/luajit/lib \
            /usr/local/openresty/lualib \
            /usr/lib/openresty/modules \
            -type f \( -name '*.so' -o -name '*.so.*' \) \
            -exec strip --strip-unneeded '{}' \; \
        && find \
            /usr/local/openresty/openssl3/bin \
            /usr/local/openresty/luajit/bin \
            -type f \
            -exec strip --strip-unneeded '{}' \; \
        ; \
    fi \
    && rundeps="$( \
        { \
            scanelf --needed --nobanner --format '%n#p' \
                /usr/sbin/openresty; \
            scanelf --needed --nobanner --format '%n#p' \
                --recursive /usr/local/openresty; \
            if [ -d /usr/lib/openresty/modules ]; then \
                scanelf --needed --nobanner --format '%n#p' \
                    --recursive /usr/lib/openresty/modules; \
            fi; \
        } \
        | tr ',' '\n' \
        | sort -u \
        | while IFS= read -r so; do \
            [ -n "$so" ] || continue; \
            for libdir in \
                /usr/local/lib \
                /usr/local/openresty/zlib/lib \
                /usr/local/openresty/openssl3/lib \
                /usr/local/openresty/pcre2/lib \
                /usr/local/openresty/luajit/lib \
            ; do \
                [ -e "$libdir/$so" ] && continue 2; \
            done; \
            printf 'so:%s\n' "$so"; \
        done \
    )" \
    && apk add --no-cache --virtual .rundeps $rundeps \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/* /tmp/*

# Add openresty utilities and LuaJIT binaries into PATH.
ENV PATH=$PATH:/usr/local/openresty/bin:/usr/local/openresty/luajit/bin

# Copy nginx configuration files.
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

COPY --chmod=755 docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests.
# See https://github.com/nginx/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

CMD ["openresty", "-g", "daemon off;"]
