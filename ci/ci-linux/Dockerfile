##[>] 🤖🤖🤖
ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE} AS ci-linux

COPY ci/tool-versions.env /tmp/tool-versions.env

ENV GOPATH=/usr/local/go-tools
ENV GOROOT=/usr/local/go
ENV PATH=/usr/local/go/bin:/usr/local/go-tools/bin:/usr/local/bin:$PATH
ENV CLICOLOR=0
ENV TF_PLUGIN_CACHE_DIR=/usr/local/terraform.d/plugin-cache

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      make git zsh curl ca-certificates clang sudo unzip xz-utils bzip2 file procps perl ruby \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) go_plat=linux-amd64; go_sha="$GO_SHA256_LINUX_AMD64" ;; \
      arm64) go_plat=linux-arm64; go_sha="$GO_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.${go_plat}.tar.gz"; \
    echo "${go_sha}  /tmp/go.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/go.tar.gz -C /usr/local; \
    rm /tmp/go.tar.gz; \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go; \
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

#[why] prebuilt bins, not go install: skip compiling their dep trees
RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) lefthook_plat=Linux_x86_64; lefthook_sha="$LEFTHOOK_SHA256_LINUX_AMD64"; yq_plat=linux_amd64; yq_sha="$YQ_SHA256_LINUX_AMD64" ;; \
      arm64) lefthook_plat=Linux_arm64; lefthook_sha="$LEFTHOOK_SHA256_LINUX_ARM64"; yq_plat=linux_arm64; yq_sha="$YQ_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /usr/local/bin/lefthook "https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_${lefthook_plat}"; \
    echo "${lefthook_sha}  /usr/local/bin/lefthook" | sha256sum -c -; \
    chmod +x /usr/local/bin/lefthook; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${yq_plat}"; \
    echo "${yq_sha}  /usr/local/bin/yq" | sha256sum -c -; \
    chmod +x /usr/local/bin/yq

#[why] --retry 10 --retry-delay 30: github.com drops out for minutes at a time from the hosted arm64 runners; a ~5min retry budget rides out the outage where the default backoff burned all retries in 3
RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) golangci_plat=linux-amd64; golangci_sha="$GOLANGCI_LINT_SHA256_LINUX_AMD64" ;; \
      arm64) golangci_plat=linux-arm64; golangci_sha="$GOLANGCI_LINT_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/golangci-lint.tar.gz "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-${golangci_plat}.tar.gz"; \
    echo "${golangci_sha}  /tmp/golangci-lint.tar.gz" | sha256sum -c -; \
    tar -xz -C /usr/local/bin --strip-components=1 -f /tmp/golangci-lint.tar.gz "golangci-lint-${GOLANGCI_LINT_VERSION}-${golangci_plat}/golangci-lint"; \
    rm /tmp/golangci-lint.tar.gz

#[why] go install, against this file's prebuilt-bins rule: gocover-cobertura publishes no release
#   binaries and its dep tree is stdlib only, so the compile is seconds. before the che layer: a che
#   release must not bust it
RUN set -eux; \
    . /tmp/tool-versions.env; \
    GOFLAGS=-mod=mod go install "github.com/t-yuki/gocover-cobertura@${GOCOVER_COBERTURA_VERSION}"; \
    gocover-cobertura --help >/dev/null 2>&1 || true

#[why] prebuilt tarballs from the package registry, not go install: skip che's slow CGO build (tree-sitter + 1Password sdk)
#   one che tarball carries the whole CLI, render subcommands included (one fetch, no checksum: version-resolved by the pipeline)
#[why] CHE_VERSION is the concrete released version, not the latest alias: the alias serves a stable etag across
#   re-uploads, so an etag-keyed layer never busts and the image keeps baking a stale che. the version changes on
#   every release, busting this layer exactly when che changes and recording what got baked in the build args
ARG CHE_VERSION
RUN set -eux; \
    : "${CHE_VERSION:?}"; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) che_plat=linux_amd64 ;; \
      arm64) che_plat=linux_arm64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    che_base_url="https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/packages/generic/che/${CHE_VERSION}"; \
    curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -o /tmp/che.tar.gz "${che_base_url}/che_${CHE_VERSION}_${che_plat}.tar.gz"; \
    tar -xz -C /usr/local/bin -f /tmp/che.tar.gz che; \
    rm /tmp/che.tar.gz

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(uname -m)"; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/zig.tar.xz "https://ziglang.org/download/${ZIG_VERSION}/zig-${arch}-linux-${ZIG_VERSION}.tar.xz"; \
    tar -xJ -C /usr/local -f /tmp/zig.tar.xz; \
    rm /tmp/zig.tar.xz; \
    ln -sf "/usr/local/zig-${arch}-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) goreleaser_plat=Linux_x86_64 ;; \
      arm64) goreleaser_plat=Linux_arm64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/goreleaser.tar.gz "https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_${goreleaser_plat}.tar.gz"; \
    tar -xz -C /usr/local/bin -f /tmp/goreleaser.tar.gz goreleaser; \
    rm /tmp/goreleaser.tar.gz

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"; \
    unzip -d /usr/local/bin /tmp/terraform.zip; \
    rm /tmp/terraform.zip

#[why] seed the plugin cache so consumers' 'terraform init' copies providers from disk, no re-download; seed files rendered from git-repos by che (docsgen), tracking its lock
COPY ci/terraform-providers.tf /tmp/tf-cache-seed/versions.tf
COPY ci/terraform.lock.hcl /tmp/tf-cache-seed/.terraform.lock.hcl
RUN set -eux; \
    mkdir -p "$TF_PLUGIN_CACHE_DIR"; \
    for i in $(seq 1 10); do \
      terraform -chdir=/tmp/tf-cache-seed init -input=false -backend=false && break; \
      [ "$i" = 10 ] && exit 1; \
      sleep 30; \
    done; \
    chmod -R a+rX "$TF_PLUGIN_CACHE_DIR"; \
    rm -rf /tmp/tf-cache-seed

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/glab.tar.gz "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${arch}.tar.gz"; \
    tar -xz -C /usr/local -f /tmp/glab.tar.gz bin/glab; \
    rm /tmp/glab.tar.gz

#[why] the onepassword terraform provider shells out to op when authing with a service account token
RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_${arch}_v${OP_VERSION}.zip"; \
    unzip -d /tmp/op /tmp/op.zip; \
    mv /tmp/op/op /usr/local/bin/op; \
    rm -rf /tmp/op /tmp/op.zip; \
    op --version

#[why] static docker CLI only: the daemon is the docker:dind CI service, apt's docker.io would drag it in
FROM ci-linux AS ci-linux-dind
RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) docker_plat=x86_64; docker_sha="$DOCKER_SHA256_LINUX_AMD64" ;; \
      arm64) docker_plat=aarch64; docker_sha="$DOCKER_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL -o /tmp/docker.tgz "https://download.docker.com/linux/static/stable/${docker_plat}/docker-${DOCKER_VERSION}.tgz"; \
    echo "${docker_sha}  /tmp/docker.tgz" | sha256sum -c -; \
    tar -xzf /tmp/docker.tgz -C /tmp docker/docker; \
    mv /tmp/docker/docker /usr/local/bin/docker; \
    rm -rf /tmp/docker /tmp/docker.tgz
##[<] 🤖🤖🤖
