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
	gcloud run services replace infra/ops/service.yaml --region=asia-northeast1

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
import: WORKSPACE=ops
import:
	terraform -chdir=infra/${WORKSPACE} import ${FLAGS} google_kms_key_ring.vault-server global/vault-server
	terraform -chdir=infra/${WORKSPACE} import ${FLAGS} google_kms_crypto_key.vault-seal global/vault-server/vault-seal

.PHONY: destroy
destory:
	terraform -chdir=infra/${WORKSPACE} destroy
	@echo Please delete the ${WORKSPACE} workspace from Terraform Cloud.

.PHONY: cleanup
cleanup: destroy
cleanup: WORKSPACE=ops
cleanup: destory
cleanup:
	gcloud run services delete vault-server --region=asia-northeast1
	@echo Done!
