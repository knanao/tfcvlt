NAME := asia.gcr.io/knanao/vault
VERSION := 1.12.2
WORKSPACE ?= dev
GCP_PROJECT ?= knanao
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
destroy:
	terraform -chdir=infra/${WORKSPACE} destroy
	@echo Please delete the ${WORKSPACE} workspace from Terraform Cloud.

.PHONY: destroy-ops
destroy-ops: WORKSPACE=ops
destroy-ops: destroy

.PHONY: cleanup
cleanup: destroy
cleanup: destroy-ops
cleanup:
	gcloud run services delete vault-server --region=asia-northeast1
	gcloud projects remove-iam-policy-binding ${GCP_PROJECT} --member="serviceAccount:terraform@${GCP_PROJECT}.iam.gserviceaccount.com" --role="roles/owner"
	gcloud iam service-accounts delete terraform@${GCP_PROJECT}.iam.gserviceaccount.com
	@echo Done!
