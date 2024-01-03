FROM sandwichimg/deepin:arm64-camel
USER root
# install essential dependencies
RUN apt-get update && apt-get install -y git make curl vim gcc-arm-linux-gnueabihf python3 bison libtool autotools-dev automake libsqlite3-dev build-essential pkg-config libcurl4-gnutls-dev libjansson-dev uthash-dev libncursesw5-dev libudev-dev libusb-1.0-0-dev libmicrohttpd-dev libhidapi-dev libgcrypt20-dev yasm xz-utils cmake net-tools 

# install gcc-8.3.0
RUN mkdir /src && cd /src && wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-8.3.0/gcc-8.3.0.tar.gz && tar -zxf gcc-8.3.0.tar.gz && cd /src/gcc-8.3.0 && ./contrib/download_prerequisites && ./configure --prefix=/usr/local/gcc-8.3.0 --enable-checking=release --enable-languages=c,c++ --disable-multilib && make -j 48 && cd /src/gcc-8.3.0 && make install && ln -s /usr/local/gcc-8.3.0 /usr/local/gcc && rm -rf /src/gcc-8.3.0 /src/gcc-8.3.0.tar.gz
ENV PATH=/usr/local/gcc/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/gcc/lib64:/usr/local/gmb/lib:/usr/local/mpfr/lib:/usr/local/mpc/lib:$LD_LIBRARY_PATH
ENV MANPATH=/usr/local/gcc/share/man:$MANPATH
ENV CPLUS_INCLUDE_PATH=$CPLUSE_INCLUDE_PATH:/usr/local/gcc-8.3.0/include/c++/8.3.0

# install openssl and libevent
RUN cd /src && wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1l.tar.gz && tar -zxf openssl-1.1.1l.tar.gz && cd openssl-1.1.1l && ./config && make -j 16 && make install && make clean && rm -rf /src/openssl-1.1.1l /src/openssl-1.1.1l.tar.gz

RUN cd /src && wget https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz && tar -zxvf libevent-2.1.12-stable.tar.gz && cd libevent-2.1.12-stable && mkdir build && cd build && cmake .. && make -j 16 && make install && make clean && rm -rf /src/libevent-2.1.12-stable.tar.gz /src/libevent-2.1.12-stable

#install boost1.8.0
RUN cd /src && wget https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/boost_1_80_0.tar.bz2 && tar -xf boost_1_80_0.tar.bz2 && cd boost_1_80_0 && ./bootstrap.sh --prefix=/usr/local/boost && cd /src/boost_1_80_0 && ./b2 install --prefix=/usr -j 32 && rm -rf /src/boost_1_80_0 boost_1_80_0.tar.bz2 
ENV CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/include
ENV LIBRARY_PATH=$LIBRARY_PATH:/usr/lib

COPY bitcoin/ /src/bitcoin/

# build bitcoin core
RUN cd /src/bitcoin && ./contrib/install_db4.sh `pwd` 
ENV BDB_PREFIX='/src/bitcoin/db4'
RUN cd /src/bitcoin && ./autogen.sh && ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --enable-wallet --without-gui --disable-tests --enable-fuzz-binary=no && cd /src/bitcoin && make -j 64 && make install && make clean && echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig && rm -rf /src/bitcoin

# install extra dependencies
RUN apt-get install -y python3-pip iperf
RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip && pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && pip3 install geoip2==2.9.0 maxminddb==1.4.1 pymysql requests jsonpath loguru dbutils==2.0

# install expect
RUN apt-get install expect libcurl4-openssl-dev build-essential autotools-dev autoconf -y 
# install cpuminer
RUN mkdir /downloads && cd /downloads && git clone https://github.com/pooler/cpuminer && cd cpuminer && ./autogen.sh && CFLAGS="-march=native" ./configure && make && make install && cd /downloads && rm -rf cpuminer
