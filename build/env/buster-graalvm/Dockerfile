ARG ARCH
FROM adtsw/build:buster-$ARCH

ARG ARCH
# Install basic utilities
RUN apt-get update && \
    apt-get install -y --force-yes gcc libz-dev upx libstdc++-8-dev

ARG VERSION=21.1.0
RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$VERSION/graalvm-ce-java11-linux-$ARCH-$VERSION.tar.gz && \
    tar -xvzf graalvm-ce-java11-linux-$ARCH-$VERSION.tar.gz && \
    rm graalvm-ce-java11-linux-$ARCH-$VERSION.tar.gz && \
    /graalvm-ce-java11-$VERSION/bin/gu install native-image
    
RUN wget http://www.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    tar -xzvf apache-maven-3.3.9-bin.tar.gz -C /var/lib/ && \
    rm apache-maven-3.3.9-bin.tar.gz
    
RUN apt-get update && \
    apt-get install -y --force-yes build-essential
    
USER adtsw
WORKDIR /home/adtsw

ENV M2_HOME=/var/lib/apache-maven-3.3.9
ENV PATH=/graalvm-ce-java11-$VERSION/bin:/var/lib/apache-maven-3.3.9/bin:$PATH
