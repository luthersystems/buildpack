# Inspired from: https://github.com/wesley-dean-flexion/busybox-jq-latest/blob/master/Dockerfile
ARG BUSYBOX_VERSION=1.35.0
ARG ALPINE_VERSION=3.17.2
ARG JQ_VERSION=1.6

FROM alpine:${ALPINE_VERSION} AS builder

ENV GIT_VERSION="2.38.5-r0"
ENV AUTOCONF_VERSION="2.71-r1"
ENV AUTOMAKE_VERSION="1.16.5-r1"
ENV LIBTOOL_VERSION="2.4.7-r1"
ENV BUILD_BASE_VERSION="0.5-r3"

WORKDIR /workdir
RUN apk add \
  --no-cache \
  git="${GIT_VERSION}" \
  autoconf="${AUTOCONF_VERSION}" \
  automake="${AUTOMAKE_VERSION}" \
  libtool="${LIBTOOL_VERSION}" \
  build-base="${BUILD_BASE_VERSION}" \
  && git clone https://github.com/stedolan/jq.git

WORKDIR /workdir/jq

RUN git submodule update --init \
  && autoreconf -fi \
  && ./configure --disable-docs --disable-maintainer-mode --with-oniguruma \
  && make -j8 LDFLAGS=-all-static \
  && strip jq

# Final stage
FROM busybox:${BUSYBOX_VERSION}

# Create the directory for the buildpack
RUN mkdir -p /opt/buildpack/bin

# Copy the jq binary from the builder stage to the desired location
COPY --from=builder /workdir/jq/jq /opt/buildpack/bin/jq
RUN chmod 755 /opt/buildpack/bin/jq

COPY bin /opt/buildpack/bin
COPY install-buildpack.sh /opt/
ENTRYPOINT ["/opt/install-buildpack.sh"]
