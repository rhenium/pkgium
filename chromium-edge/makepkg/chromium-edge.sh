#!/bin/sh

# Allow users to override command-line options
# Based on Gentoo's chromium package (and by extension, Debian's)
for f in /etc/chromium-edge/* ; do
   [[ -f ${f} ]] && source "${f}"
done

# Prefer user defined CHROMIUM_USER_FLAGS (from env) over system
# default CHROMIUM_FLAGS (from /etc/chromium-edge/default)
CHROMIUM_FLAGS=${CHROMIUM_USER_FLAGS:-$CHROMIUM_FLAGS}

export CHROME_WRAPPER=$(readlink -f "$0")
export CHROME_DESKTOP="chromium-edge.desktop"
export SSLKEYLOGFILE=$HOME/.local/share/sslkey.log

exec /usr/lib/chromium-edge/chrome ${CHROMIUM_FLAGS} "$@"
