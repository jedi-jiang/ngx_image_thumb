#!/bin/bash

function write_image_conf() {
  mkdir -p $BASEDIR/test-data/var/log/nginx
cat <<EOF > $BASEDIR/test-data/conf/image.conf
worker_processes  1;

error_log  $BASEDIR/test-data/var/log/nginx/error.log;

events {
    worker_connections  1024;
}


http {
  types {
      text/html                             html htm shtml;
      text/css                              css;
      text/xml                              xml;
      image/gif                             gif;
      image/jpeg                            jpeg jpg;
      application/x-javascript              js;
      application/atom+xml                  atom;
      application/rss+xml                   rss;

      text/mathml                           mml;
      text/plain                            txt;
      text/vnd.sun.j2me.app-descriptor      jad;
      text/vnd.wap.wml                      wml;
      text/x-component                      htc;

      image/png                             png;
      image/tiff                            tif tiff;
      image/vnd.wap.wbmp                    wbmp;
      image/x-icon                          ico;
      image/x-jng                           jng;
      image/x-ms-bmp                        bmp;
      image/svg+xml                         svg svgz;
      image/webp                            webp;

      application/java-archive              jar war ear;
      application/mac-binhex40              hqx;
      application/msword                    doc;
      application/pdf                       pdf;
      application/postscript                ps eps ai;
      application/rtf                       rtf;
      application/vnd.ms-excel              xls;
      application/vnd.ms-powerpoint         ppt;
      application/vnd.wap.wmlc              wmlc;
      application/vnd.google-earth.kml+xml  kml;
      application/vnd.google-earth.kmz      kmz;
      application/x-7z-compressed           7z;
      application/x-cocoa                   cco;
      application/x-java-archive-diff       jardiff;
      application/x-java-jnlp-file          jnlp;
      application/x-makeself                run;
      application/x-perl                    pl pm;
      application/x-pilot                   prc pdb;
      application/x-rar-compressed          rar;
      application/x-redhat-package-manager  rpm;
      application/x-sea                     sea;
      application/x-shockwave-flash         swf;
      application/x-stuffit                 sit;
      application/x-tcl                     tcl tk;
      application/x-x509-ca-cert            der pem crt;
      application/x-xpinstall               xpi;
      application/xhtml+xml                 xhtml;
      application/zip                       zip;

      application/octet-stream              bin exe dll;
      application/octet-stream              deb;
      application/octet-stream              dmg;
      application/octet-stream              eot;
      application/octet-stream              iso img;
      application/octet-stream              msi msp msm;

      audio/midi                            mid midi kar;
      audio/mpeg                            mp3;
      audio/ogg                             ogg;
      audio/x-m4a                           m4a;
      audio/x-realaudio                     ra;

      video/3gpp                            3gpp 3gp;
      video/mp4                             mp4;
      video/mpeg                            mpeg mpg;
      video/quicktime                       mov;
      video/webm                            webm;
      video/x-flv                           flv;
      video/x-m4v                           m4v;
      video/x-mng                           mng;
      video/x-ms-asf                        asx asf;
      video/x-ms-wmv                        wmv;
      video/x-msvideo                       avi;
  }
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

  server {
      listen          8080;
      server_name     _;

      rewrite "^/goodsImg/(.*)!([0-9]{2,4})x([0-9]{2,4})\.(jpg|png)$"  /goodsImg/\$1.\$4!c\$2x\$3.\$4 last;
      rewrite "^/goodsImgNW/(.*)!([0-9]{2,4})([0-9]{2,4})\.(jpg|png)$"  /goodsImgNW/\$1.\$4!c\$2x\$3.\$4 last;

      location ~ "/goodsImg/.*c([0-9]{2,4})x([0-9]{2,4})\.(gif|jpg|jpeg|bmp|png|ico)$"
      {
          root $BASEDIR/test-data/images;
          image on;
          image_use_imagick on; 
          image_output on;
          image_jpeg_quality 100;
          image_water on;
          image_water_type 0;
          image_water_pos 5;
          image_water_file $basedir/test-data/images/watermark.png;
          image_water_transparent 100;
          expires      7d;
      }

      location ~ "/goodsImgNW/.*c([0-9]{2,4})x([0-9]{2,4})\.(gif|jpg|jpeg|bmp|png|ico)$"
      {
          root $BASEDIR/test-data/images;
          image on;
          image_output on;
          image_jpeg_quality 100;
          image_water off;
          expires      7d;
      }
  }
}
EOF
}

EXE="$0"
EXEDIR=`dirname "$EXE"`
BASEDIR=`cd "$EXEDIR" && pwd -P`
NGINXBIN="$BASEDIR/BUILD/nginx-1.4.0/objs/nginx"
if [ ! -f "$NGINXBIN" ] ; then
  echo "Please build the nginx with ngx_image_thumb first!"
  exit 1
fi
echo "Writting nginx conf file $BASEDIR/test-data/conf/image.conf ..."
write_image_conf
echo "Written nginx conf file successfully"
IPADDR=`ip -4 addr | grep inet | awk '{if ($2 !~ /127\.0\.0\.1/) print substr($2,1,index($2,"/")-1);}'`
echo "You could use following url to to the test."
echo "http://$IPADDR:8080/goodsImg/20109a01!300x300.jpg"
echo "http://$IPADDR:8080/goodsImg/detail!400x000.jpg"
echo ""

"$NGINXBIN" -g "daemon off; master_process off;" -c "$BASEDIR/test-data/conf/image.conf"

