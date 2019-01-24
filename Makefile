SERVICE=iot-console
RUNDIR=/opt/accelerando/$(SERVICE)
SHELL=/bin/bash
ARCH?=arm
ENVIRONMENT?=dev

go: build run

run:    fixperms
	docker-compose up

start:  fixperms
	docker-compose up -d

stop:
	docker-compose stop

nuke:
	docker-compose down

fixperms:
	sudo chown -R 1001 node-red

config:
	@[ -e config.inc ] || ln -s config-${ENVIRONMENT}.inc config.inc
	@[ -e docker-compose.yml ] || ln -s docker-compose-$(ENVIRONMENT).yml docker-compose.yml
	@[ -e Dockerfile-filebeat ] || ln -s Dockerfile-filebeat-$(ARCH) Dockerfile-filebeat
	@[ -e Dockerfile-broker ] || ln -s Dockerfile-broker-$(ARCH) Dockerfile-broker

build: images

images: installdeps
	docker-compose build

install: installdeps
	sudo cp $(SERVICE).service /etc/systemd/system/
	sudo systemctl daemon-reload
	sudo systemctl enable $(SERVICE)
	sudo systemctl restart $(SERVICE)

installdeps: 
	@true

clean:
	@rm -f *~ .*~
	@for s in Dockerfile-broker Dockerfile-filebeat config.inc docker-compose.yml ; do [ -L "$$s" ] && rm $$s ; done


