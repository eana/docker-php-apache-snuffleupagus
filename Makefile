.DEFAULT_GOAL := image

# -- Variables --
# The name of the app
APP = "wordpress-snuffleupagus"
# The git tag for the version
TAG ?= $(shell curl -s https://registry.hub.docker.com/v1/repositories/wordpress/tags | jq --raw-output '.[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]' | awk '/php7/ && /apache/' | sort -rh | head -n1 2>/dev/null)

# The docker tags
DOCKER_REGISTRY_URL = "395500896865.dkr.ecr.eu-west-1.amazonaws.com"
DOCKER_TAG = "${DOCKER_REGISTRY_URL}/${APP}:${TAG}"

# -- High level targets --
# We only list these targets in the help. The other targets can still be used
# but it is generally better to call one of these.

.PHONY: help
help: ## Prints this help
ifneq ($(.DEFAULT_GOAL),)
	@echo "Default target: \033[36m$(.DEFAULT_GOAL)\033[0m"
endif
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: image
image: ## Builds a docker image and tags it based on ${TAG}
ifeq ("$(TAG)","")
	@echo "${TAG}"
	@echo "Need TAG when building the docker image."
	@exit 1
endif
	@echo "Building Docker Image ${DOCKER_TAG}"
	@docker build -t ${DOCKER_TAG} .

.PHONY: push
push: image aws_login ## Builds and pushes the docker image to ECR
	@echo "Pushing ${DOCKER_TAG}"
	@docker push "${DOCKER_TAG}"

# -- Low level targets --
# These targets are more low level and not included in the help. You can call
# them directly but generally you would use the higher level target.

.PHONY: aws_login
aws_login:
	@echo "Logging docker into AWS"
	@aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${DOCKER_REGISTRY_URL}
