PROJECT = october

start : run

build :
	docker build -t $(PROJECT) .
pull :
	docker pull quay.io/3scale/ruby:2.0

run :
	docker run --rm -t -i $(PROJECT) $(CMD)
bash : CMD = bash
bash : run
