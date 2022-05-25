export CGO_ENABLED=0

run-test: s3proxy.jar
	./test/run-tests.sh

s3proxy.jar:
	wget https://github.com/gaul/s3proxy/releases/download/s3proxy-1.8.0/s3proxy -O s3proxy.jar

get-deps: s3proxy.jar
	go get -t ./...

build:
	go build -ldflags "-X main.Version=`git rev-parse HEAD`"

install:
	go install -ldflags "-X main.Version=`git rev-parse HEAD`"



SERVICE=goofys
PATH_DOCKER_FILE=$(realpath ./build/Dockerfile)
DOCKER_REGISTRY_ENTRY=$(AWS_ECR_REGISTRY)/core/$(SERVICE)

ifneq ($(GIT_TAG),)
	IMAGE_TAG = $(GIT_TAG)
else ifeq ($(GIT_BRANCH),master)
	IMAGE_TAG = "latest"
else ifneq ($(GIT_BRANCH),)
	IMAGE_TAG = $(GIT_BRANCH)
endif

.PHONY: docker_image_build
docker_image_build:
	@echo ">>> Building docker image"
	docker build \
		-t $(SERVICE) \
		--build-arg GIT_REPO="$(GIT_REPO)" \
		--build-arg GIT_TAG="$(GIT_TAG)" \
		--build-arg GIT_BRANCH="$(GIT_BRANCH)" \
		--build-arg GIT_COMMIT="$(GIT_COMMIT)" \
		-f $(PATH_DOCKER_FILE) \
		.

.PHONY: docker_image_inspect
docker_image_inspect:
	@echo ">>> Inspecting docker container"
	docker inspect \
		-f '{{index .ContainerConfig.Labels "repo"}}' \
		-f '{{index .ContainerConfig.Labels "tag"}}' \
		-f '{{index .ContainerConfig.Labels "branch"}}' \
		-f '{{index .ContainerConfig.Labels "commit"}}' \
		$(SERVICE)

.PHONY: docker_image_registry_push
docker_image_registry_push:
	@echo ">>> Tag and push docker image"
	@docker tag $(SERVICE) $(DOCKER_REGISTRY_ENTRY):$(IMAGE_TAG)
	@docker push $(DOCKER_REGISTRY_ENTRY):$(IMAGE_TAG)
