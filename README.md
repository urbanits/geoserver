# GEOSERVER 2.20.4 WITH ECW EXTENSION

![Geoserver.org](https://upload.wikimedia.org/wikipedia/commons/9/9e/GeoServer_logo.png)


### Geoserver

in *web.xml* CORS Enabled , other settings is default from source https://geoserver.org

### GDAL

Version 2.2.2

### ECW Lib

Version 3.3 SDK

### Java

OpenJDK 11

### Plugins

Only GDAL Extension from source

## System layer

### Linux Ubuntu 18.04 LTS

### Packages

``autoconf
automake
build-essential
curl
libpng-dev
unzip
software-properties-common
openjdk-11-jre-headless
repository ppa:ubuntugis/ubuntugis-unstable
g++
gcc
libgdal-dev
libgeos-dev
libspatialite-dev
make
wget
libgdal-java_2.2.3+dfsg-2_amd64.deb
libgdal20_2.2.3+dfsg-2_amd64.deb ``


## Container usage

In system with installed Docker use command to download the image

`` docker pull urbanits/geoserver:master ``

To run without parameters:

`` docker run -d -p <host_port>:8080 urbanits/geoserver:master ``

If you want to use Geoserver with your local files you should use *-v* option to connect volume

``  docker run -d -p <host_port>:8080 -v <host/path/to/dir>:/opt/geoserver/data_dir urbanits/geoserver:master  ``

After running container will be available on *http://localhost:<host_port>/geoserver*


