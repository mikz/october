FROM quay.io/3scale/ruby:2.0
MAINTAINER Michal Cichra <michal@3scale.net> # 2014-06-16

RUN apt-get -q update && apt-get -y -q install libcurl4-openssl-dev redis-server
RUN apt-get -y -q install fortunes fortunes-mario fortunes-off fortunes-spam fortune-mod fortunes-min fortunes-bofh-excuses

VOLUME /var/lib/redis/

WORKDIR /tmp/october/

ADD Gemfile /tmp/october/
ADD Gemfile.lock /tmp/october/
ADD october.gemspec /tmp/october/
ADD lib/october/version.rb /tmp/october/lib/october/

RUN bundle install --without development test --jobs `grep -c processor /proc/cpuinfo`

WORKDIR /opt/october/
ADD . /opt/october/
# ADD irc.yml config/irc.yml
# ADD plugins.yml config/irc.yml
RUN bundle install --without development test

CMD redis-server /etc/redis/redis.conf && bundle exec october
