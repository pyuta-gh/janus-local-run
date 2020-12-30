# How to use
# Create a local operating environment for Janus for Web RTC in a Docker container.

# Image build method
# docker build -t image-name .

# Start container from image
# docker run -itd -p 8088:8088 -p 8000:8000 --name janus -d image-name

# Base Image Debian
FROM debian

# OS Update
RUN apt-get update

# Required library installation
RUN apt install libmicrohttpd-dev libjansson-dev libssl-dev \
 libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev \
 libcurl4-openssl-dev liblua5.3-dev libconfig-dev \
 pkg-config gengetopt libtool automake gtk-doc-tools doxygen \
 graphviz libnanomsg-dev cmake -y --fix-missing

# Install the command used for installation
RUN apt-get install -y wget && \
 apt-get install vim -y && \
 apt-get install git -y && \
 apt-get install -y curl

# libnice
RUN PATH="/usr/local/bin:$PATH"
RUN yes | apt install python3-pip
RUN yes | pip3 install meson
RUN yes | pip3 install ninja
RUN cd /root && \
  git clone https://gitlab.freedesktop.org/libnice/libnice && \
  cd ./libnice && \
  meson --prefix=/usr build && ninja -C build && ninja -C build install

# libsrtp
RUN cd /root && \
  wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz && \
  tar xfv v2.2.0.tar.gz && \
  cd libsrtp-2.2.0 && \
  ./configure --prefix=/usr --enable-openssl && \
  make shared_library && make install

# usrsctp
RUN cd /root && \
  git clone https://github.com/sctplab/usrsctp && \
  cd ./usrsctp && \
  ./bootstrap && \
  ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 && \
   make && make install

# libwebsockets
RUN cd /root && \
  git clone https://libwebsockets.org/repo/libwebsockets && \
  cd ./libwebsockets && \
  mkdir build && \
  cd ./build && \
  cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 \
  -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
  make && make install

# Install the Janus server itself
RUN cd /root && \
  git clone https://github.com/meetecho/janus-gateway.git && \
  cd janus-gateway && \
  sh autogen.sh && \
  ./configure --prefix=/opt/janus && \
  make && \
  make install && \
  make configs

# Set up Janus Demo client
# node,npm
RUN apt-get install nodejs npm -y && \
  npm install n -g -y && \
  n stable && \
  apt purge -y nodejs npm

# Simple WEB server (local-web-server) installation
RUN npm install -g local-web-server -y

# Set Janus launch shell
RUN cd /root/janus-gateway/ && \
  touch run_janus.sh && \
  echo "#!/bin/sh" >>run_janus.sh && \
  echo "/opt/janus/bin/janus &" >>run_janus.sh && \
  echo "cd /root/janus-gateway/html" >>run_janus.sh && \
  echo "ws" >>run_janus.sh && \
  chmod 755 run_janus.sh

EXPOSE 8000 8088

USER root

CMD ["/root/janus-gateway/run_janus.sh"]
