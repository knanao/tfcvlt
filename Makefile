NAME := asia.gcr.io/knanao/vault
VERSION := 1.12.2

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
	terraform -chdir=infra init

.PHONY: fmt
fmt: FLAGS ?=
fmt:
	terraform -chdir=infra fmt $(FLAGS)

.PHONY: validate
validate: FLAGS ?= 
validate:
	terraform -chdir=infra validate $(FLAGS)

.PHONY: plan
plan: FLAGS ?=
plan:
	terraform -chdir=infra plan $(FLAGS)

.PHONY: apply
apply: FLAGS ?=
apply:
	terraform -chdir=infra apply $(FLAGS)

.PHONY: vault-init
vault-init:
	terraform -chdir=infra/vault init

.PHONY: vault-import
vault-import: FLAGS ?= -var-file=../terraform.tfvars
vault-import:
	terraform -chdir=infra/vault import ${FLAGS} google_kms_key_ring.vault-server global/vault-server
	terraform -chdir=infra/vault import ${FLAGS} google_kms_crypto_key.vault-seal global/vault-server/vault-seal

.PHONY: vault-plan
vault-plan: FLAGS ?= -var-file=../terraform.tfvars
vault-plan:
	terraform -chdir=infra/vault plan $(FLAGS)

.PHONY: vault-apply
vault-apply: FLAGS ?= -var-file=../terraform.tfvars
vault-apply: 
	terraform -chdir=infra/vault apply $(FLAGS)

.PHONY: vault-destroy
vault-destroy: FLAGS ?= -var-file=../terraform.tfvars
vault-destroy: 
	terraform -chdir=infra/vault destroy $(FLAGS)
