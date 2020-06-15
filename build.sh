#!/bin/bash
EXE="$0"
EXEDIR=`dirname "$EXE"`
BASEDIR=`cd "$EXEDIR/" && pwd -P`
BUILDDIR="${BASEDIR}/BUILD"
NGINXSRCDIR="$BUILDDIR/nginx-1.4.0"
if [ "$1" == "-resetbuildenv" ] ; then
  if [ -d "$BUILDDIR" ] ; then
    rm -fr "$BUILDDIR"
    echo "Done!"
    exit 0
  fi
fi
if [ ! -d "$BUILDDIR" ] ; then
  mkdir -p "$BUILDDIR"
fi

if [ ! -d "$NGINXSRCDIR" ] ; then
  cd "$BUILDDIR"
  tar xzf ../nginx-1.4.0.tar.gz
  cd "$NGINXSRCDIR"
  ln -s $BASEDIR ngx_image_thumb
fi

cd "$NGINXSRCDIR"

if [ "$1" == "-clean" ]; then
  make clean
  echo "Done!"
  exit 0
fi
./configure --prefix=/usr/local/nginx-image --with-cc-opt="-DMAGICKCORE_QUANTUM_DEPTH=16 -DMAGICKCORE_HDRI_ENABLE=0" --with-http_stub_status_module $@ --add-module=./ngx_image_thumb
make
