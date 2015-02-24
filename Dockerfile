FROM quay.io/3scale/ruby:2.1
MAINTAINER Michal Cichra <michal@3scale.net> # 2014-06-16

RUN apt-install libcurl4-openssl-dev redis-server \
	        fortunes fortunes-mario fortunes-off fortunes-spam fortune-mod fortunes-min fortunes-bofh-excuses

VOLUME /var/lib/redis/

WORKDIR /opt/october/

ADD Gemfile Gemfile.lock october.gemspec /opt/october/
ADD lib/october/version.rb /opt/october/lib/october/

RUN bundle install --without development test --jobs `grep -c processor /proc/cpuinfo`

ADD . /opt/october/

CMD redis-server /etc/redis/redis.conf && bundle exec bin/october
