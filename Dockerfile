# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
ARG APP_VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"
LABEL org.opencontainers.image.source="https://github.com/thespad/docker-apcupsd_exporter"
LABEL org.opencontainers.image.url="https://github.com/thespad/docker-apcupsd_exporter"

ARG GOCACHE=/tmp \
    GOOS=linux \
    CGO_ENABLED=0

RUN \
  apk add --update --no-cache --virtual=build-dependencies \
    go && \
  echo "**** install apcupsd_exporter ****" && \
  mkdir -p /tmp/apcupsd_exporter && \
  if [ -z ${APP_VERSION+x} ]; then \
    APP_VERSION=$(curl -sX GET "https://api.github.com/repos/mdlayher/apcupsd_exporter/tags" | \
    jq -r '.[0] | .name' ); \
  fi && \
  curl -s -o \
    /tmp/apcupsd_exporter.tar.gz -L \
    "https://github.com/mdlayher/apcupsd_exporter/archive/refs/tags/${APP_VERSION}.tar.gz"  && \
  tar xf \
    /tmp/apcupsd_exporter.tar.gz -C \
    /tmp/apcupsd_exporter/ --strip-components=1 && \
  cd /tmp/apcupsd_exporter && \
  go build -o /usr/local/bin/apcupsd_exporter ./cmd/apcupsd_exporter && \
  echo "**** installed apcupsd_exporter version ${APP_VERSION} ****" && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/go

COPY root/ /

EXPOSE 9162/tcp
