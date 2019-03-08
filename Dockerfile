FROM nginx:1.14

MAINTAINER Mohammad Hosseinz Zadeh Abbas mhzuser96@gmail.com


RUN apt-get update
RUN mkdir /etc/nginx/modsec
RUN apt-get install -y \
    apt-utils \
    autoconf \
    automake \
    build-essential \
    git \
    libcurl4-openssl-dev \
    libgeoip-dev liblmdb-dev \
    libpcre++-dev \
    libtool \
    libxml2-dev \
    libyajl-dev \
    pkgconf \
    wget \
    zlib1g-dev

RUN git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
WORKDIR /ModSecurity
RUN git submodule init && git submodule update && ./build.sh && ./configure 
RUN make && make install 

WORKDIR /
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
RUN wget http://nginx.org/download/nginx-1.14.2.tar.gz
RUN tar xzf nginx-1.14.2.tar.gz


WORKDIR /nginx-1.14.2
RUN ./configure --with-compat --add-dynamic-module=../ModSecurity-nginx
RUN make modules
RUN cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules

WORKDIR /

RUN wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
RUN mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf

COPY ./modsec/nginx.conf /etc/nginx/nginx.conf
ADD ./modsec/main.conf /etc/nginx/modsec/
COPY ./modsec/default.conf /etc/nginx/conf.d/default.conf
