FROM ruby:2.5-alpine

RUN apk --no-cache add \
  tzdata

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apk --no-cache add --virtual build-dependencies \
  build-base \
  sqlite-dev \
  && bundle install --without development test \
&& apk del build-dependencies

COPY . .

LABEL maintainer="Justin Coyne <jcoyne@justincoyne.com>"

CMD puma -C config/puma.rb
