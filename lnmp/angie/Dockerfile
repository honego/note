# SPDX-License-Identifier: BSD-2-Clause
# Copyright (c) 2026 honeok <i@honeok.com>

# References:
# https://cn.angie.software/angie/docs/installation
# https://github.com/nginx/docker-nginx

# https://cn.angie.software/angie/docs/installation/oss_packages
FROM alpine:3.23.5@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40 AS base

FROM base AS dist

## angie
ARG ANGIE_VERSION=1.12.1
ENV ANGIE_VERSION $ANGIE_VERSION

RUN set -ex \
    && addgroup -g 101 -S angie \
    && adduser -S -D -H -u 101 -h /var/cache/angie -s /sbin/nologin -G angie -g angie angie \
    && apk add --no-cache \
        curl \
        ca-certificates \
        gettext-envsubst \
        tzdata \
# download the public key of the Angie repo for package verification.
    && curl -fsSL https://angie.software/keys/angie-signing.rsa -o /etc/apk/keys/angie-signing.rsa \
    && angiePackages=angie=$( \
        apk query --no-cache --from none --all-matches \
            --repository "@angie https://download.angie.software/angie/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" \
            --fields version angie \
            | sed -n "s/^Version: \($ANGIE_VERSION-r[0-9][0-9]*\)$/\1/p" | sort -V | tail -n 1 \
    ) \
# we need to make sure angie.software packages are pulled in, which isnt guaranteed
# as Alpine repos might have the same version in the repos.
# query angie.software binaries for the dependencies
    && angieDeps=$(apk query --summarize depends --recursive --no-cache \
            --repository "@angie https://download.angie.software/angie/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" \
            ${angiePackages/=/@angie=}) \
# install those dependencies from alpine repos
            && apk add --no-cache $angieDeps \
# limit apk to angie.software repos only to install the requested packages
    && apk add --repositories-file /dev/null -X "https://download.angie.software/angie/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $angiePackages
