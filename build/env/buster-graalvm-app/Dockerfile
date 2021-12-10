ARG ARCH
FROM adtsw/build:buster-graalvm-$ARCH

ARG APP_NAME
ARG ARCH

RUN sudo mkdir -p /var/log/$APP_NAME && sudo chown adtsw:adtsw /var/log/$APP_NAME  
COPY $APP_NAME /usr/local/share/$APP_NAME
RUN sudo chown -R adtsw:adtsw /usr/local/share/$APP_NAME

USER adtsw
WORKDIR /home/adtsw

