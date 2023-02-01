#!/command/with-contenv /bin/bash

variables='${PHP_MEMORY_LIMIT}:${PHP_ERROR_REPORTING}:${UPLOAD_POST_BODY_MAX_MB}:${TZ}'
envsubst "${variables}" <"$(dirname $0)/php-fpm.conf.tmpl" >"/etc/php${PHP_VERSION}/php-fpm.conf"
envsubst "${variables}" <"$(dirname $0)/php.ini.tmpl" >"/etc/php${PHP_VERSION}/php.ini"
