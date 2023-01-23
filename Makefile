NAME := asia.gcr.io/knanao/vault
VERSION := 1.12.2
WORKSPACE ?= dev
FLAGS ?=

.PHONY: build
build:
	docker build -t ${NAME}:${VERSION} \
	--progress=plain  \
	--build-arg VAULT_VERSION=${VERSION} infra/vault
	
.PHONY: push
push:
	docker push ${NAME}:v${VERSION}

.PHONY: deploy
deploy: build push
deploy:
	@echo Done!

.PHONY: replace
replace:
	gcloud run services replace infra/vault/service.yaml --region=asia-northeast1

.PHONY: init
init:
	terraform -chdir=infra/${WORKSPACE} init

.PHONY: fmt
fmt:
	terraform -chdir=infra/${WORKSPACE} fmt $(FLAGS)

.PHONY: validate
validate:
	terraform -chdir=infra/${WORKSPACE} validate $(FLAGS)

.PHONY: plan
plan:
	terraform -chdir=infra/${WORKSPACE} plan $(FLAGS)

.PHONY: apply
apply:
	terraform -chdir=infra/${WORKSPACE} apply $(FLAGS)

.PHONY: import
import:
	terraform -chdir=infra/${WORKSPACE} import ${FLAGS} google_kms_key_ring.vault-server global/vault-server
	terraform -chdir=infra/${WORKSPACE} import ${FLAGS} google_kms_crypto_key.vault-seal global/vault-server/vault-seal

.PHONY: cleanup
cleanup:
	terraform -chdir=infra/dev destroy $(FLAGS)
	terraform -chdir=infra/ops destroy $(FLAGS)
