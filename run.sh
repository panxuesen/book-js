#!/usr/bin/env bash

SCRIPT_PATH=$(cd `dirname "$0"`;pwd)
cd "${SCRIPT_PATH}";

[ -d ./public/fonts ] || mkdir -p ./public/fonts
[ -d ./public/pdf ] || mkdir -p ./public/pdf
[ -d ./public/img ] || mkdir -p ./public/img

chmod 755 ./install-font.sh && ./install-font.sh

yarn start
