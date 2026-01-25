FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf && \
    rm -rf /usr/share/nginx/html/*

RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

COPY --chown=nginx:nginx conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY --chown=nginx:nginx html/ /usr/share/nginx/html/

USER nginx

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD [ curl -f http://localhost/ || exit 1 ]


