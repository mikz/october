PROJECT = october

start : run

build :
	docker build -t $(PROJECT) .

run :
	docker run --rm --env OCTOBER_ENV=$(OCTOBER_ENV) --net=host -t -i $(PROJECT) $(CMD)

bash : CMD = bash
bash : run
