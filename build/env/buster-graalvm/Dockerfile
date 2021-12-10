FROM adtsw/build:buster

# Install basic utilities
RUN apt-get update && \
    apt-get install -y --force-yes gcc libz-dev upx libstdc++-8-dev

ARG VERSION=21.1.0
RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$VERSION/graalvm-ce-java11-linux-amd64-$VERSION.tar.gz && \
    tar -xvzf graalvm-ce-java11-linux-amd64-$VERSION.tar.gz && \
    rm graalvm-ce-java11-linux-amd64-$VERSION.tar.gz && \
    /graalvm-ce-java11-$VERSION/bin/gu install native-image
    
RUN wget http://www.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    tar -xzvf apache-maven-3.3.9-bin.tar.gz -C /var/lib/ && \
    rm apache-maven-3.3.9-bin.tar.gz
    
RUN apt-get update && \
    apt-get install -y --force-yes build-essential
    
ARG RESULT_LIB="/var/lib/static"

RUN mkdir ${RESULT_LIB}

RUN curl -L -o musl.tar.gz https://musl.libc.org/releases/musl-1.2.1.tar.gz && \
    mkdir musl && tar -xvzf musl.tar.gz -C musl --strip-components 1 && cd musl && \
    ./configure --disable-shared --prefix=${RESULT_LIB} && \
    make && make install && \
    cd / && rm -rf /muscl && rm -f /musl.tar.gz

RUN cp /usr/lib/gcc/x86_64-linux-gnu/8/libstdc++.a ${RESULT_LIB}/lib/

ENV PATH="$PATH:${RESULT_LIB}/bin"
ENV CC="musl-gcc"

RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.11.tar.gz && \
   mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && cd zlib && \
   ./configure --static --prefix=${RESULT_LIB} && \
    make && make install && \
    cd / && rm -rf /zlib && rm -f /zlib.tar.gz
    
USER adtsw
WORKDIR /home/adtsw

ENV CC="musl-gcc"
ENV M2_HOME=/var/lib/apache-maven-3.3.9
ENV PATH=/graalvm-ce-java11-$VERSION/bin:/var/lib/apache-maven-3.3.9/bin:$PATH
