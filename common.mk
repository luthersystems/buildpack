PROJECT=buildpack
PROJECT_PATH=github.com/luthersystems/${PROJECT}

TAG_SUFFIX ?= -amd64
GIT_TAG ?= $(shell git describe --tags --exact-match 2>/dev/null)
GIT_REVISION ?= $(shell git rev-parse --short HEAD)
VERSION ?= $(if $(strip $(GIT_TAG)),$(GIT_TAG),$(GIT_REVISION))
BUILD_VERSION ?= ${VERSION}${TAG_SUFFIX}

CP=cp
RM=rm
DOCKER=docker
DOCKER_RUN_OPTS=--rm
DOCKER_RUN=${DOCKER} run ${DOCKER_RUN_OPTS}

# The Makefile determines whether to build a container or not by consulting a
# dummy file that is touched whenever the container is built.  The function,
# IMAGE_DUMMY, computes the path to the dummy file.
DUMMY_TARGET=build/$(1)/$(2)/.dummy
IMAGE_DUMMY=$(call DUMMY_TARGET,image,$(1))
PUSH_DUMMY=$(call DUMMY_TARGET,push,$(1))
MANIFEST_DUMMY=$(call DUMMY_TARGET,manifest,$(1))
FQ_DOCKER_IMAGE ?= docker.io/$(1)

MKDIR_P=mkdir -p
TOUCH=touch
GZIP=gzip
GUNZIP=gunzip
TIME_P=time -p
TAR=tar

# print out make variables, e.g.:
# make echo:VERSION
echo\:%:
	@echo $($*)
