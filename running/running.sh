#!/bin/bash
set -euo pipefail

exec sudo /usr/bin/shellinaboxd --no-beep --user=${shellinabox_USER} --group=${shellinabox_USER} --port=${shellinabox_PORT} --css=/etc/shellinabox/options-enabled/00_WhiteOnBlack.css --disable-ssl