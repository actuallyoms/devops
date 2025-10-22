# 1. Base image
FROM nginx:alpine

# 2. index.html dosyasını container içine kopyala
COPY index.html /usr/share/nginx/html/index.html

# 3. Nginx default port
EXPOSE 80

# 4. Nginx çalıştır
CMD ["nginx", "-g", "daemon off;"]
