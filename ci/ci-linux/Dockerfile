##[>] 🤖🤖🤖
FROM debian:bookworm-slim

COPY ci/tool-versions.env /tmp/tool-versions.env

ENV GOPATH=/usr/local/go-tools
ENV GOROOT=/usr/local/go
ENV PATH=/usr/local/go/bin:/usr/local/go-tools/bin:/usr/local/bin:$PATH
ENV CLICOLOR=0
ENV TF_PLUGIN_CACHE_DIR=/usr/local/terraform.d/plugin-cache

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      make git zsh curl ca-certificates clang sudo unzip xz-utils bzip2 file procps perl \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) goplat=linux-amd64; gosha="$GO_SHA256_LINUX_AMD64" ;; \
      arm64) goplat=linux-arm64; gosha="$GO_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.${goplat}.tar.gz"; \
    echo "${gosha}  /tmp/go.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/go.tar.gz -C /usr/local; \
    rm /tmp/go.tar.gz; \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go; \
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

#[why] prebuilt bins, not go install: skip compiling their dep trees
RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) lhplat=Linux_x86_64; lhsha="$LEFTHOOK_SHA256_LINUX_AMD64"; yqplat=linux_amd64; yqsha="$YQ_SHA256_LINUX_AMD64" ;; \
      arm64) lhplat=Linux_arm64; lhsha="$LEFTHOOK_SHA256_LINUX_ARM64"; yqplat=linux_arm64; yqsha="$YQ_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL -o /usr/local/bin/lefthook "https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_${lhplat}"; \
    echo "${lhsha}  /usr/local/bin/lefthook" | sha256sum -c -; \
    chmod +x /usr/local/bin/lefthook; \
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${yqplat}"; \
    echo "${yqsha}  /usr/local/bin/yq" | sha256sum -c -; \
    chmod +x /usr/local/bin/yq

#[why] go install via proxy.golang.org, not the github release tarball: github.com is intermittently unreachable from the hosted arm64 runners; the module proxy is a Google CDN and sum.golang.org verifies integrity (replacing the pinned sha256)
RUN set -eux; \
    . /tmp/tool-versions.env; \
    GOBIN=/usr/local/bin GOFLAGS=-buildvcs=false /usr/local/go/bin/go install "github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v${GOLANGCI_LINT_VERSION}"; \
    rm -rf /root/go /root/.cache/go-build

#[why] prebuilt tarballs from the package registry, not go install: skip che's slow CGO build (tree-sitter + 1Password sdk)
#   one che tarball bundles che + render-tpl (one fetch, no checksum: latest alias)
#[why] CHE_REF busts this layer only when the latest che tarball changed: CI passes its etag, so an unchanged che keeps the cached layer, a new che re-runs the fetch
ARG CHE_REF=latest
RUN set -eux; \
    : "${CHE_REF}"; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) plat=linux_amd64 ;; \
      arm64) plat=linux_arm64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    che_base="https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/packages/generic/che/latest"; \
    curl -fsSL --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -o /tmp/che.tar.gz "${che_base}/che_latest_${plat}.tar.gz"; \
    tar -xz -C /usr/local/bin -f /tmp/che.tar.gz che render-tpl; \
    rm /tmp/che.tar.gz

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(uname -m)"; \
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL -o /tmp/zig.tar.xz "https://ziglang.org/download/${ZIG_VERSION}/zig-${arch}-linux-${ZIG_VERSION}.tar.xz"; \
    tar -xJ -C /usr/local -f /tmp/zig.tar.xz; \
    rm /tmp/zig.tar.xz; \
    ln -sf "/usr/local/zig-${arch}-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) grplat=Linux_x86_64 ;; \
      arm64) grplat=Linux_arm64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL -o /tmp/goreleaser.tar.gz "https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_${grplat}.tar.gz"; \
    tar -xz -C /usr/local/bin -f /tmp/goreleaser.tar.gz goreleaser; \
    rm /tmp/goreleaser.tar.gz

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"; \
    unzip -d /usr/local/bin /tmp/terraform.zip; \
    rm /tmp/terraform.zip

#[why] seed the plugin cache so consumers' 'terraform init' copies providers from disk, no re-download; seed files rendered from git-repos by che (docsgen), tracking its lock
COPY ci/terraform-providers.tf /tmp/tf-cache-seed/versions.tf
COPY ci/terraform.lock.hcl /tmp/tf-cache-seed/.terraform.lock.hcl
RUN set -eux; \
    mkdir -p "$TF_PLUGIN_CACHE_DIR"; \
    terraform -chdir=/tmp/tf-cache-seed init -input=false -backend=false; \
    chmod -R a+rX "$TF_PLUGIN_CACHE_DIR"; \
    rm -rf /tmp/tf-cache-seed

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL -o /tmp/glab.tar.gz "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${arch}.tar.gz"; \
    tar -xz -C /usr/local -f /tmp/glab.tar.gz bin/glab; \
    rm /tmp/glab.tar.gz
##[<] 🤖🤖🤖
