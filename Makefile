NAME := asia.gcr.io/knanao/vault
VERSION := v1.12.2

.PHONY: build
build:
	docker build -t ${NAME}:${VERSION} \
	--progress=plain  \
	--build-arg VAULT_VERSION=${VERSION} .
	
.PHONY: push
push:
	docker push ${NAME}:${VERSION}

.PHONY: deploy
deploy: build push
deploy:
	@echo Done!

.PHONY: replace
replace:
	gcloud run services replace vault.yaml

.PHONY: init
init:
	terraform -chdir=infra init

.PHONY: fmt
fmt: FLAGS ?=
fmt:
	terraform -chdir=infra fmt $(FLAGS)

.PHONY: validate
validate: FLAGS ?= 
validate:
	terraform validate $(FLAGS)

.PHONY: plan
plan: FLAGS ?=
plan:
	terraform -chdir=infra plan $(FLAGS)

.PHONY: apply
apply: FLAGS ?=
apply:
	terraform -chdir=infra apply $(FLAGS)
