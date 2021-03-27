FROM nginx:stable-alpine
#FROM gliderlabs/alpine:3.2
#FROM fluent/fluentd:v1.12.1-1.0

ENV ENTRYKIT_VERSION 0.4.0

RUN apk add --no-cache openssl \
  && rm -rf /var/cache/apk/* \
  && wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete' has no effect
RUN apk update \
  && apk add --no-cache \
  ca-certificates \
  ruby ruby-irb ruby-etc ruby-webrick \
  tini \
  && apk add --no-cache --virtual .build-deps \
  build-base linux-headers \
  ruby-dev gnupg \
  && echo 'gem: --no-document' >> /etc/gemrc \
  && gem install oj -v 3.10.18 \
  && gem install json -v 2.4.1 \
  && gem install async-http -v 0.54.0 \
  && gem install ext_monitor -v 0.1.2 \
  && gem install fluentd -v 1.12.1 \
  && gem install bigdecimal -v 1.4.4 \
  && apk del .build-deps \
  && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/2.*/gems/fluentd-*/test

RUN addgroup -S fluent && adduser -S -g fluent fluent \
  # for log storage (maybe shared with host)
  && mkdir -p /fluentd/log \
  # configuration/plugins path (default: copied from .)
  && mkdir -p /fluentd/etc /fluentd/plugins \
  && chown -R fluent /fluentd && chgrp -R fluent /fluentd

COPY fluentd/fluent.conf /fluentd/etc/
COPY fluentd/entrypoint.sh /bin/


ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
EXPOSE 24224 5140

#USER fluent

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD index.html /index.html

ENTRYPOINT [ \
  "codep", \
  "tini -- /bin/entrypoint.sh fluentd", \
    "/docker-entrypoint.sh nginx" \
]

#ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
#CMD ["fluentd"]