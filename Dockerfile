# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t geo_test_again .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name geo_test_again geo_test_again

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
# Используем официальный образ Ruby
FROM ruby:3.3.5-slim

# Устанавливаем зависимости для importmap
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y  cron nodejs npm \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips \
    postgresql-client &&\
    rm -rf /var/lib/apt/lists/* &&\
    cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# Настройка окружения
ENV RAILS_ROOT=/var/www/geo_test_again
RUN mkdir -p $RAILS_ROOT

# Set working directory
WORKDIR $RAILS_ROOT

# Установка гемов
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Копирование приложения
COPY . .

# Компиляция ассетов
RUN bundle exec rails assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
