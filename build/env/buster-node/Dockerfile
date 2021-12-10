FROM adtsw/build:buster

# Install basic utilities
RUN apt-get update && \
    apt-get install -y --force-yes gcc fakeroot zip

USER adtsw
WORKDIR /home/adtsw

ENV NODE_VERSION=14.16.1
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.38.0/install.sh | bash
ENV NVM_DIR=/home/adtsw/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin":$PATH
