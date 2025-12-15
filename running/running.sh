#!/bin/bash
set -euo pipefail

exec sudo /usr/bin/shellinaboxd --no-beep --user=${shellinabox_USER} --group=${shellinabox_USER} --port=${shellinabox_PORT} -q \
 -c /var/lib/shellinabox \
 --disable-ssl \
 --user-css "Normal:+/etc/shellinabox/options-enabled/00_White On Black.css;Colors:+/etc/shellinabox/options-enabled/01+Color Terminal.css"