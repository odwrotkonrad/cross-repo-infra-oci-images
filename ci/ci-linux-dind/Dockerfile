##[>] 🤖🤖
ARG BASE=registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:latest
FROM $BASE

COPY ci/tool-versions.env /tmp/tool-versions.env

#[why] static docker CLI only: the daemon is the docker:dind CI service, apt's docker.io would drag it in
RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) dplat=x86_64; dsha="$DOCKER_SHA256_LINUX_AMD64" ;; \
      arm64) dplat=aarch64; dsha="$DOCKER_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/docker.tgz "https://download.docker.com/linux/static/stable/${dplat}/docker-${DOCKER_VERSION}.tgz"; \
    echo "${dsha}  /tmp/docker.tgz" | sha256sum -c -; \
    tar -xzf /tmp/docker.tgz -C /tmp docker/docker; \
    mv /tmp/docker/docker /usr/local/bin/docker; \
    rm -rf /tmp/docker /tmp/docker.tgz
##[<] 🤖🤖
