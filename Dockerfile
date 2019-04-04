FROM ruby:2.5-alpine

# netcat is required by wait-for in invoke.sh
RUN apk --no-cache add \
  postgresql-dev \
  netcat-openbsd \
  tzdata

RUN mkdir /app
WORKDIR /app

ADD https://raw.githubusercontent.com/eficode/wait-for/master/wait-for ./wait-for
RUN chmod +x wait-for

COPY Gemfile Gemfile.lock docker/invoke.sh ./
RUN chmod +x invoke.sh

RUN apk --no-cache add --virtual build-dependencies \
  build-base \
  && bundle install --without development test\
&& apk del build-dependencies

COPY . .

LABEL maintainer="Justin Coyne <jcoyne@justincoyne.com>"
LABEL description="The workflow server suitable for testing other applications in \
                   DLSS.  This should not be used for production as it uses invoke.sh \
                   which performs database migrations automatically. This could be \
                   problematic if deployed as a cluster because we don't want all \
                   nodes to try to run the migrations."
ENV RAILS_ENV=production

CMD ["./invoke.sh"]
