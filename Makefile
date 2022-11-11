RUNDECK_VERSION := "4.5.0"
DOCKER_VERSION := "${RUNDECK_VERSION}-1"
DOCKER_NAME := "rundeck"
DOCKER_IMAGE := "nledez/${DOCKER_NAME}:${DOCKER_VERSION}"

all: build push push_consul_version

.PHONY: run_standalone
run_standalone:
	docker container run -d --name rundeck --rm rundeck/rundeck:${RUNDECK_VERSION}

.PHONY: update_defaults
update_defaults:
	docker cp rundeck:/home/rundeck/etc defaults/etc/${RUNDECK_VERSION}
	docker cp rundeck:/etc/remco defaults/remco/${RUNDECK_VERSION}

.PHONY: kill_standalone
kill_standalone:
	docker kill rundeck

.PHONY: build
build:
	docker build -t ${DOCKER_IMAGE} .

.PHONY: push
push:
	docker push ${DOCKER_IMAGE}

.PHONY: push_consul_version
push_consul_version:
	consul kv get ${DOCKER_NAME}/docker_tag || true
	consul kv put ${DOCKER_NAME}/docker_tag ${DOCKER_VERSION}
	consul kv get ${DOCKER_NAME}/docker_tag
