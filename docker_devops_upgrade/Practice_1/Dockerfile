# slurm-webpage/Dockerfile
# Используем базовый образ Nginx
FROM nginx:alpine

# Копируем файл index.html в директорию Nginx по умолчанию
COPY index.html /usr/share/nginx/html/

# Документируем порт 80 для доступа
EXPOSE 80