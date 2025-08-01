FROM nginx:alpine

COPY ./frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./frontend/artifact/default/ /usr/share/nginx/html

EXPOSE 80