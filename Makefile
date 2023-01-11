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
