# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Mike Adolphs <mike@fooforge.com>

# Scan deb mirror for updated packages
RUN /usr/bin/apt-get update
RUN /bin/mkdir /root/.ssh

# Install dependencies
RUN /usr/bin/apt-get install -qy build-essential curl git openssh-client

# Install rbenv/Ruby
RUN /usr/bin/apt-get install -qy zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN /usr/bin/ssh-keyscan -H github.com >> /root/.ssh/known_hosts

RUN /usr/bin/git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN /usr/bin/git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ./root/.rbenv/plugins/ruby-build/install.sh

ENV PATH /root/.rbenv/bin:$PATH
RUN /bin/echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN /bin/echo 'eval "$(rbenv init -)"' >> .bashrc

ENV CONFIGURE_OPTS --disable-install-doc
RUN /bin/bash -c 'rbenv install 2.0.0-p353'
RUN /bin/bash -c 'rbenv global 2.0.0-p353'
RUN /bin/bash -c 'rbenv rehash'

RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN /bin/bash -lc 'gem install bundler'

# Install nginx
RUN /usr/bin/apt-get install -qy nginx 
RUN /bin/echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80

# Clone and build fooforge.com
RUN /usr/bin/git clone https://github.com/fooforge/fooforge.com.git /var/www/fooforge.com/
RUN /bin/bash -lc 'cd /var/www/fooforge.com; bundle'
RUN /bin/bash -lc 'cd /var/www/fooforge.com; jekyll build'

ADD .docker/nginx-fooforge.com /etc/nginx/sites-available/fooforge.com
RUN /bin/bash -c '/bin/ln -s /etc/nginx/sites-available/fooforge.com /etc/nginx/sites-enabled/fooforge.com'

CMD service nginx start

