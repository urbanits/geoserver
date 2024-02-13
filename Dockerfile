FROM ubuntu:18.04
MAINTAINER Maxim Romanenko<romanenko@urban-its.ru>

ENV DEBIAN_FRONTEND noninteractive

#Install system packages
RUN apt-get -qq update \
    && apt-get -qq -y install \
    autoconf \
    automake \
    build-essential \
    curl \
    libpng-dev\
    unzip \
    software-properties-common \
    openjdk-11-jre-headless \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable && apt-get update\
    && apt-get -qq -y install \
    g++ \
    gcc \
    libgdal-dev \
    libgeos-dev \
    libspatialite-dev \
    make \
    wget && \
    apt-mark hold libgdal-dev libgeos-dev libspatialite-dev \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gdal/libgdal-java_2.2.3+dfsg-2_amd64.deb \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gdal/libgdal20_2.2.3+dfsg-2_amd64.deb \
    && dpkg -i libgdal-java_2.2.3+dfsg-2_amd64.deb libgdal20_2.2.3+dfsg-2_amd64.deb \
    && apt-get -f install \
    && dpkg -i libgdal-java_2.2.3+dfsg-2_amd64.deb libgdal20_2.2.3+dfsg-2_amd64.deb; exit 0

# Copy geoserver from repository
WORKDIR /opt/geoserver
COPY geoserver .

#Build ECW libs from repository
ENV ECW_DIR /usr/local
WORKDIR /tmp
COPY libecwj2-3.3 .
WORKDIR /tmp/libecwj2-3.3
RUN ./configure && \
    make && \
    make install 

# Build GDAL from source
ENV GDAL_VERSION 2.2.2
RUN mkdir -p /usr/local/src && \
    curl http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz | \
    tar xz -C /usr/local/src

WORKDIR /usr/local/src/gdal-$GDAL_VERSION
RUN ./configure \
    --with-ecw=$ECW_DIR \
    --with-spatialite \
    && make clean \
    && make \
    && make install \
    && ldconfig

WORKDIR /tmp/libecwj2-3.3
RUN make clean

WORKDIR /usr/local/src/gdal-$GDAL_VERSION
RUN make clean

# Geoserver Environmet variables
ENV GEOSERVER_HOME /opt/geoserver
#ENV JAVA_HOME /usr
ENV GDAL_DATA /usr/local/share/gdal/
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib

##
## PLUGINS INSTALLATION if need
##
ENV GEOSERVER_VERSION 2.20.4
ENV GEOSERVER_URL http://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION
#
## Get GeoServer from source
#RUN wget -c $GEOSERVER_URL/geoserver-$GEOSERVER_VERSION-bin.zip -O ~/geoserver.zip && \
#    unzip ~/geoserver.zip -d /opt && mv -v /opt/geoserver* /opt/geoserver && \
#    rm ~/geoserver.zip
#
## Get some plugin

ENV PLUGIN vectortiles
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

ENV PLUGIN mbtiles
RUN wget -c https://build.geoserver.org/geoserver/2.20.x/community-2024-02-13/geoserver-2.20-SNAPSHOT-mbtiles-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip


ENV PLUGIN wps
RUN wget -c https://sourceforge.net/projects/geoserver/files/GeoServer/2.20.4/extensions/geoserver-2.20.4-wps-plugin.zip/download -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Expose GeoServer's default port
EXPOSE 8080
WORKDIR /opt/geoserver/data_dir
CMD ["/opt/geoserver/bin/startup.sh"]
