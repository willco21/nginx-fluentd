#FROM nginx:stable-alpine
#FROM gliderlabs/alpine:3.2
FROM fluent/fluentd:v1.12.1-1.0

ENV ENTRYKIT_VERSION 0.4.0

USER root

RUN apk add openssl \
  && rm -rf /var/cache/apk/* \
  && wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

RUN apk add nginx
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/index.html /index.html
RUN mkdir -p /run/nginx

ENTRYPOINT [ \
  "codep", \
    "tini -- /bin/entrypoint.sh fluentd", \
    "/usr/sbin/nginx" \
]

#ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
#CMD ["fluentd"]