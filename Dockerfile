FROM mhart/alpine-node:6.1.0

MAINTAINER PRX <sysadmin@prx.org>

ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
RUN chmod +x /tini

WORKDIR /app
EXPOSE 3000

ENTRYPOINT ["/tini", "--", "npm", "run"]
CMD ["server:dist"]

ADD . ./

RUN apk --update add --virtual build-dependencies git && \
    npm set progress=false && \
    npm install --ignore-scripts --production --no-optional --unsafe-perm --loglevel error && \
    npm run build:dist && \
    npm prune --production --loglevel error && npm cache clean && \
    rm -rf jspm_packages typings .dev && \
    apk del build-dependencies && \
    ((find / -type f -iname \*.apk-new -delete || true); \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* ; \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf ; \
    rm -rf /usr/share/man /tmp/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html)