# variables
UNAME := $(shell uname -a)
NAME = gitops-deployer

# this is for local run only
default: up

# pls sort alphabetically
# pls make sure all api repository applied the same code below if you modify it

build: reset
rebuild: reset
reset: down owner timeout
	docker-compose -f docker-compose.yml build
	docker-compose -f docker-compose.yml up -d --remove-orphans
	make package
	make down

crontab:
	docker-compose -f docker-compose.yml exec -T app-app bash -c "\
	echo "" > /etc/cron.d/crontab && \
    tail /var/www/deploy/*.cron | tee -a /etc/cron.d/crontab && \
    sed -i '1i PATH="/usr/local/bin:/usr/bin:/bin"' /etc/cron.d/crontab && \
    chmod 0744 /etc/cron.d/crontab && \
    crontab /etc/cron.d/crontab && \
    touch /var/log/cron.log && \
    service cron restart && service cron status"

down:
	docker ps -a -q | xargs -n 1 -P 8 -I {} docker stop {}
	docker builder prune --all --force
	docker system prune -f

init: destroy
destroy: down timeout
	docker volume prune -f
	docker-compose -f docker-compose.yml build --no-cache
	docker-compose -f docker-compose.yml up -d --remove-orphans
	make package

owner:
	cd ../$(NAME) && chown -R :www-data . # ubuntu

package: timeout package owner

package:
	docker-compose -f docker-compose.yml exec -T app-app bash -c "cd /var/www/html/$(NAME) && \
	[ -f go.mod ] || go mod init webcoderio/$(gitops-deployer) && go mod tidy"

report:
	git shortlog -s -n -e

restart: down up

serve:
	docker-compose -f docker-compose.yml exec -T app-app bash -c "cd /var/www/html/$(NAME) && \
	go build && ./$(NAME)"

ssh: timeout
	docker-compose -f docker-compose.yml exec app-app bash

timeout:
	export DOCKER_CLIENT_TIMEOUT=2000
	export COMPOSE_HTTP_TIMEOUT=2000

# this is for local run only
up: down timeout owner
	docker-compose -f docker-compose.yml up -d --remove-orphans
	make package
	make serve
