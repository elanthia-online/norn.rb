#
# Dockerfile for Norn.rb
#
FROM alpine
MAINTAINER Ondreian <noreply@gmail.com>

ENV SRC /usr/src/norn
ENV SCRIPTS /var/lib/scripts

WORKDIR $SRC
VOLUME $SCRIPTS

RUN set -ex \
    && apk add -U bash \
                  ruby ruby-dev ruby-bundler \
                  openssl \
    && apk add -t TMP build-base \
                      curl \
                      git \
                      krb5-dev \
                      openssl-dev \
                      sqlite \
                      sqlite-dev \
                      tar

ADD . / ./
RUN bundle install
CMD scripts/entrypoint
EXPOSE 4040
