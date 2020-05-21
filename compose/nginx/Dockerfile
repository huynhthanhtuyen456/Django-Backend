FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /root/project/nginx -p
WORKDIR /root/project/nginx

COPY ./compose/nginx/setup.sh setup.sh
RUN chmod +x setup.sh
RUN ./setup.sh

COPY ./compose/nginx/sites-enabled/default /etc/nginx/sites-enabled/default

COPY ./compose/django/entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
