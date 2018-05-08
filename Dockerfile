FROM ruby:2.5-alpine

RUN apk update && apk add build-base sqlite-dev tzdata

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

COPY . .

LABEL maintainer="Justin Coyne <jcoyne@justincoyne.com>"

CMD puma -C config/puma.rb
