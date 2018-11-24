class Image < ApplicationRecord

  belongs_to :user



  def self.generate_file(name,pg,redis,nginx,ruby_ver,user)
    f = File.new("./files/Dockerfile","w")
    f.puts("FROM ruby:"+ruby_ver.to_s+"-alpine

    RUN apk --update add --virtual\
    build-dependencies build-base libev libev-dev postgresql-dev nodejs nodejs-npm bash\
    tzdata sqlite-dev git curl libxml2-dev gcc libxslt-dev


    # for nokogiri
    # RUN apt-get install -y libxml2-dev libxslt1-dev libpq-dev

    # for a JS runtime
    # RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
    # RUN apt-get install -y nodejs

    # for yarn
    # RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    # RUN echo \"deb https://dl.yarnpkg.com/debian/ stable main\" | tee /etc/apt/sources.list.d/yarn.list
    # RUN apt-get update -qq && apt-get install -y yarn
    RUN npm install -g yarn
    RUN bundle config build.nokogiri --use-system-libraries
    WORKDIR /app
    #ADD .gemrc /app
    ADD Gemfile /app/
    ADD Gemfile.lock /app/

    ENV RAILS_ENV=development
    ENV NODE_ENV=development

    # Modify bundle config to use local gem cache and then do bundle install
    RUN bundle install --jobs 8

    # ADD package.json /app/

    RUN yarn install

    ADD . /app

    EXPOSE 3000
    CMD [\"bundle\", \"exec\", \"rails\", \"s\"]")
    f.close
    f=File.open(File.join(Rails.root,"/files/Dockerfile"))
    user.dockerfile=f
    user.save!

    f=File.open(File.join(Rails.root,"/files/docker-compose.yml"),"w")
    if pg==true and redis==false
      f.puts("version: '3'
      services:
        web:
          build: .
          image: "+name.to_s+":latest
          ports:
            - \"3000:3000\"
          expose:
            - \"3000\"
          dns: \"8.8.8.8\"
          volumes:
            - \".:/app\"
          #env_file: .env
          restart: always
          links:
            - db:db
          command: bash -c \"bin/rake assets:precompile && bin/rake db:create && bin/rake db:migrate && bin/rails s -b 0.0.0.0\"

        db:
          image: postgres:latest
          volumes:
            - dbdata:/var/lib/postgresql/data  ")
    elsif pg==false and redis==true
      f.puts("version: '3'
      services:
        web:
          build: .
          image: "+name.to_s+":latest
          ports:
            - \"3000:3000\"
          expose:
            - \"3000\"
          dns: \"8.8.8.8\"
          volumes:
            - \".:/app\"
          #env_file: .env
          restart: always
          links:
            - redis:redis
          command: bash -c \"bin/rake assets:precompile && bin/rake db:create && bin/rake db:migrate && bin/rails s -b 0.0.0.0\"

        redis:
            image: redis:latest  ")
    elsif pg==true and redis==true
      f.puts("version: '3'
      services:
        web:
          build: .
          image: "+name.to_s+":latest
          ports:
            - \"3000:3000\"
          expose:
            - \"3000\"
          dns: \"8.8.8.8\"
          volumes:
            - \".:/app\"
          #env_file: .env
          restart: always
          links:
            - redis:redis
            -db:db
          command: bash -c \"bin/rake assets:precompile && bin/rake db:create && bin/rake db:migrate && bin/rails s -b 0.0.0.0\"

        redis:
            image: redis:latest
        db:
            image: postgres:latest
            volumes:
              - dbdata:/var/lib/postgresql/data  ")

        else
          f.puts("version: '3'
services:
  web:
    build: .
    image: "+name.to_s+":latest
    ports:
      - \"3000:3000\"
    expose:
      - \"3000\"
    dns: \"8.8.8.8\"
    volumes:
      - \".:/app\"
    #env_file: .env
    restart: always
    command: bash -c \"bin/rake assets:precompile && bin/rake db:create && bin/rake db:migrate && bin/rails s -b 0.0.0.0\"")
    end

    if nginx==true
      f.puts("\n  proxy:
        image: jwilder/nginx-proxy
        restart: always
        depends_on:
          - web
        volumes:
          - /var/run/docker.sock:/tmp/docker.sock:ro
        ports:
          - \"80:80\"
        container_name: proxy")
    end

    f.close
    path=File.join(Rails.root,"/files/docker-compose.yml")
    f=File.open(path)
    user.composefile=f
    user.save!
  end
end
