FROM quay.io/3scale/ruby:2.0
MAINTAINER Michal Cichra <michal@3scale.net> # 2014-06-16

RUN apt-get -q update && apt-get -y -q install libcurl4-openssl-dev
RUN apt-get -y -q install fortunes fortunes-mario fortunes-off fortunes-spam fortune-mod fortunes-min fortunes-bofh-excuses

WORKDIR /tmp/

ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
ADD october.gemspec /tmp/

RUN bundle install --without development test --jobs `grep -c processor /proc/cpuinfo`

WORKDIR /opt/october/
ADD . /opt/october/
RUN rm config/redis.yml
# ADD irc.yml config/irc.yml
# ADD plugins.yml config/irc.yml
RUN bundle install --without development test

CMD rake start[3scale]
