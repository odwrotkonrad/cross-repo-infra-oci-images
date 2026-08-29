##[>] 🤖🤖
ARG BUILDER_IMAGE=alpine:3
ARG BASE_IMAGE=gcr.io/distroless/static-debian13:nonroot

FROM ${BUILDER_IMAGE} AS fetch
ARG CHE_VERSION
ARG TARGETARCH
RUN set -eux; \
    : "${CHE_VERSION:?}"; \
    apk add --no-cache curl; \
    mkdir -p /out; \
    che_base_url="https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/packages/generic/che/${CHE_VERSION}"; \
    curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -o /tmp/che.tar.gz "${che_base_url}/che_${CHE_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    tar -xz -C /out -f /tmp/che.tar.gz che

FROM ${BASE_IMAGE} AS che
COPY --from=fetch /out/che /usr/local/bin/che
ENTRYPOINT ["/usr/local/bin/che"]
##[<] 🤖🤖
