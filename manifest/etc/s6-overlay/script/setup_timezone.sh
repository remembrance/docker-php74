#!/command/with-contenv bash

if [ -n "${TZ}" ]; then
  ln -snf "/usr/share/zoneinfo/${TZ}" /var/run/s6/localtime
  echo "${TZ}" >/var/run/s6/timezone
fi
