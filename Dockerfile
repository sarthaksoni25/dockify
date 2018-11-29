FROM ruby:2.4-alpine

    RUN apk --update add --virtual    build-dependencies build-base libev libev-dev postgresql-dev nodejs nodejs-npm bash    tzdata sqlite-dev git curl libxml2-dev gcc libxslt-dev


    # for nokogiri
    # RUN apt-get install -y libxml2-dev libxslt1-dev libpq-dev

    # for a JS runtime
    # RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
    # RUN apt-get install -y nodejs

    # for yarn
    # RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    # RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
    # RUN apt-get update -qq && apt-get install -y yarn
    RUN npm install -g yarn
    RUN bundle config build.nokogiri --use-system-libraries
    RUN bundle config build.nio4r --with-cflags="-std=c99"
    WORKDIR /app
    #ADD .gemrc /app
    ADD Gemfile /app/
    ADD Gemfile.lock /app/

    ENV RAILS_ENV=development
    ENV NODE_ENV=development

    # Modify bundle config to use local gem cache and then do bundle install
    #RUN gem install nokogiri -v '1.8.5'
    RUN bundle install --jobs 8

    # ADD package.json /app/

    RUN yarn install

    ADD . /app

    EXPOSE 3000
    CMD ["bundle", "exec", "rails", "s"]
