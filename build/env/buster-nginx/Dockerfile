ARG ARCH
FROM adtsw/build:buster-$ARCH

ARG ARCH

RUN apt-get update && apt-get install -y nginx

RUN sudo mkdir -p /var/log/nginx && sudo chown -R adtsw:adtsw /var/log/nginx
RUN touch /var/log/nginx/error.log && chown adtsw:adtsw /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
    
USER adtsw
WORKDIR /home/adtsw

# CMD ["nginx", "-g", "daemon off;"]