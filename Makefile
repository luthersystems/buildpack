PROJECT_REL_DIR=./
include ${PROJECT_REL_DIR}/common.mk

STATIC_IMAGE ?= ${PROJECT}
PUBLIC_STATIC_IMAGE ?= luthersystems/${PROJECT}
STATIC_IMAGE_DUMMY=$(call IMAGE_DUMMY,${STATIC_IMAGE}/${VERSION})
FQ_STATIC_IMAGE=$(call FQ_DOCKER_IMAGE,${PUBLIC_STATIC_IMAGE})
FQ_STATIC_IMAGE_DUMMY=$(call PUSH_DUMMY,${FQ_STATIC_IMAGE}/${BUILD_VERSION})
FQ_MANIFEST_DUMMY=$(call MANIFEST_DUMMY,${FQ_STATIC_IMAGE}/${BUILD_VERSION})

.PHONY: default
default: build
	@

.PHONY: clean
clean:
	${RM} -rf ./build/*

.PHONY: build
build: ${STATIC_IMAGE_DUMMY}
	@

${STATIC_IMAGE_DUMMY}: Makefile Dockerfile bin/detect bin/build bin/release install-buildpack.sh
	${MKDIR_P} $(dir $@)
	@echo "Building buildpack docker image: ${STATIC_IMAGE}"
	${TIME_P} ${DOCKER} build \
		-t ${STATIC_IMAGE}:latest \
		-t ${STATIC_IMAGE}:${VERSION} \
		-f Dockerfile .
	${TOUCH} $@

.PHONY: push
push: ${FQ_STATIC_IMAGE_DUMMY}
	@

${FQ_STATIC_IMAGE_DUMMY}: ${STATIC_IMAGE_DUMMY}
	${DOCKER} tag ${STATIC_IMAGE}:${VERSION} ${FQ_STATIC_IMAGE}:${BUILD_VERSION}
	${DOCKER} push ${FQ_STATIC_IMAGE}:${BUILD_VERSION}
	${MKDIR_P} $(dir $@)
	${TOUCH} $@

.PHONY: push-manifests
push-manifests: ${FQ_MANIFEST_DUMMY}
	@

${FQ_MANIFEST_DUMMY}:
	${DOCKER} buildx imagetools create \
		--tag ${FQ_STATIC_IMAGE}:latest \
		${FQ_STATIC_IMAGE}:${VERSION}-arm64 \
		${FQ_STATIC_IMAGE}:${VERSION}-amd64
	${DOCKER} buildx imagetools create \
		--tag ${FQ_STATIC_IMAGE}:${VERSION} \
		${FQ_STATIC_IMAGE}:${VERSION}-arm64 \
		${FQ_STATIC_IMAGE}:${VERSION}-amd64
