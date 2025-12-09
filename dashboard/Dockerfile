FROM nginx:alpine

RUN rm -r /etc/nginx/conf.d/default.conf

COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

COPY html/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD [ curl -f http://localhost/ || exit 1 ]


