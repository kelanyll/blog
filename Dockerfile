FROM nginx
COPY public/. /www/data
COPY nginx.conf /etc/nginx/nginx.conf
