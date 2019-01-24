#!/bin/bash
EXE="$0"
EXEDIR=`dirname "$EXE"`
BASEDIR=`cd "$EXEDIR/.." && pwd -P`
cd "$BASEDIR"
if [ "$1" == "-clean"]; then
  make clean
  ./configure --prefix=/usr/local/nginx-image --with-http_stub_status_module $@ --add-module=./ngx_image_thumb
fi
make
