# Dockerfile
FROM squidfunk/mkdocs-material

# Копируем все содержимое репозитория в директорию /docs
COPY . /docs

# Рабочая директория
WORKDIR /docs

# Команда для запуска mkdocs сервера
CMD ["mkdocs", "serve", "--dev-addr", "0.0.0.0:8000"]
