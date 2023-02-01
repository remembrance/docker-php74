#!/command/with-contenv /bin/bash

variables='${DOCUMENT_ROOT}:${NGINX_LISTEN_PORT}:${UPLOAD_POST_BODY_MAX_MB}'
envsubst "${variables}" <"$(dirname $0)/default.conf.tmpl" >/etc/nginx/http.d/default.conf
envsubst "${variables}" <"$(dirname $0)/nginx.conf.tmpl" >/etc/nginx/nginx.conf
