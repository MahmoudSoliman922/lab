FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev \
    librdkafka-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile ./
RUN bundle install

COPY . .

CMD ["bundle", "exec", "ruby", "main.rb"]
