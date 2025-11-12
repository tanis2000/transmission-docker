BUILD_VERSION := $(shell git describe --tags HEAD)
export BUILD_VERSION

.PHONY: build
build:
	docker build -t tanis2000/transmission:local -t tanis2000/transmission:$(BUILD_VERSION) -f Dockerfile .

.PHONY: publish
publish:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t tanis2000/transmission:$(BUILD_VERSION) --push -f Dockerfile .
